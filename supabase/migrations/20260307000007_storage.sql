-- Create storage bucket for food images
INSERT INTO storage.buckets (id, name, public)
VALUES ('food-images', 'food-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for food-images bucket

-- Allow anyone to view food images (public access)
DROP POLICY IF EXISTS "Anyone can view food images" ON storage.objects;
CREATE POLICY "Anyone can view food images"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'food-images');

-- Allow authenticated users to upload food images
DROP POLICY IF EXISTS "Authenticated users can upload food images" ON storage.objects;
CREATE POLICY "Authenticated users can upload food images"
  ON storage.objects
  FOR INSERT
  WITH CHECK (bucket_id = 'food-images' AND auth.role() = 'authenticated');

-- Allow users to update their own food images
DROP POLICY IF EXISTS "Users can update own food images" ON storage.objects;
CREATE POLICY "Users can update own food images"
  ON storage.objects
  FOR UPDATE
  USING (bucket_id = 'food-images' AND auth.uid() = owner)
  WITH CHECK (bucket_id = 'food-images' AND auth.uid() = owner);

-- Allow users to delete their own food images
DROP POLICY IF EXISTS "Users can delete own food images" ON storage.objects;
CREATE POLICY "Users can delete own food images"
  ON storage.objectscha
  FOR DELETE
  USING (bucket_id = 'food-images' AND auth.uid() = owner);
