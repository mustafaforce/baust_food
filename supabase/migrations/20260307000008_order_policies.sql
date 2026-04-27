-- Update orders RLS policies to allow vendors to see orders containing their food items

-- Drop existing policies
DROP POLICY IF EXISTS "Customers can view own orders" ON public.orders;
DROP POLICY IF EXISTS "Customers can create orders" ON public.orders;

-- Allow customers to view their own orders
CREATE POLICY "Customers can view own orders"
  ON public.orders
  FOR SELECT
  USING (auth.uid() = customer_id);

-- Allow customers to create orders
CREATE POLICY "Customers can create orders"
  ON public.orders
  FOR INSERT
  WITH CHECK (auth.uid() = customer_id);

-- Allow vendors to view orders containing their food items
-- This requires a function to check if the order contains vendor's food items
CREATE OR REPLACE FUNCTION public.vendor_can_view_order(order_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  vendor_user_id uuid;
  vendor_food_count int;
BEGIN
  vendor_user_id := auth.uid();

  IF vendor_user_id IS NULL THEN
    RETURN false;
  END IF;

  -- Check if the user is a vendor
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = vendor_user_id AND role = 'vendor'
  ) THEN
    RETURN false;
  END IF;

  -- Check if order contains any food items from this vendor
  SELECT COUNT(*)
  INTO vendor_food_count
  FROM public.order_items oi
  JOIN public.food_items fi ON oi.food_item_id = fi.id
  WHERE oi.order_id = vendor_can_view_order.order_id
    AND fi.vendor_id = vendor_user_id;

  RETURN vendor_food_count > 0;
END;
$$;

-- Allow vendors to view orders containing their food items
CREATE POLICY "Vendors can view orders with their items"
  ON public.orders
  FOR SELECT
  USING (public.vendor_can_view_order(id));

-- Allow vendors to update order status (but not other fields)
CREATE POLICY "Vendors can update order status"
  ON public.orders
  FOR UPDATE
  USING (public.vendor_can_view_order(id))
  WITH CHECK (
    public.vendor_can_view_order(id)
    AND (
      -- Can only update status
      status IN ('accepted', 'preparing', 'ready', 'delivered', 'cancelled')
      OR status IS NOT NULL
    )
  );

-- Order items policies
DROP POLICY IF EXISTS "Customers can view own order items" ON public.order_items;
DROP POLICY IF EXISTS "Customers can create order items" ON public.order_items;

-- Allow customers to view order items for their orders
CREATE POLICY "Customers can view own order items"
  ON public.order_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_id
      AND orders.customer_id = auth.uid()
    )
  );

-- Allow customers to create order items for their orders
CREATE POLICY "Customers can create order items"
  ON public.order_items
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_id
      AND orders.customer_id = auth.uid()
    )
  );

-- Allow vendors to view order items for orders containing their food
CREATE POLICY "Vendors can view order items for their food"
  ON public.order_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.food_items
      WHERE food_items.id = food_item_id
      AND food_items.vendor_id = auth.uid()
    )
  );
