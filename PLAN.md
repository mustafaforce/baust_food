# BAUST Food - Implementation Plan

## Overview
A Flutter-based campus food ordering app for BAUST (Bangladesh Army University of Science & Technology) with role-based access (Admin, Vendor, Customer).

---

## App Flow

### User Flows

#### 1. Authentication Flow
```
Launch App → Login/Signup → Dashboard
                      ↓
              Password Reset (if needed)
```

#### 2. Customer Flow
```
Dashboard → Browse Menu → Search/Filter → Add to Cart → Place Order → Order History
                                ↓                              ↓
                          View Details                  Order Status Updates
```

#### 3. Vendor Flow
```
Vendor Login → Vendor Dashboard → View Orders → Update Status (Accept/Prepare/Ready)
                    ↓
              Manage Menu (Add/Edit/Delete Items)
```

#### 4. Admin Flow
```
Admin Login → Admin Dashboard → Manage Users → Assign Roles
                    ↓
              View All Orders → Analytics
```

### Role-Based Access

| Feature | Customer | Vendor | Admin |
|---------|----------|--------|-------|
| Browse Menu | ✓ | ✓ | ✓ |
| Add to Cart | ✓ | ✗ | ✗ |
| Place Orders | ✓ | ✗ | ✗ |
| View Own Orders | ✓ | ✓ | ✓ |
| Manage Menu | ✗ | ✓ | ✓ |
| Manage Users | ✗ | ✗ | ✓ |
| View All Orders | ✗ | ✗ | ✓ |

### Data Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Flutter   │ ←→  │   Supabase  │ ←→  │    Users    │
│    App      │     │  Database   │     │  (Auth)     │
└─────────────┘     └─────────────┘     └─────────────┘
       ↓                   ↓
┌─────────────┐     ┌─────────────┐
│   Cart      │     │  Food Items │
│  (Local)    │     │  Categories │
└─────────────┘     │   Orders    │
                    └─────────────┘
```

### Key Pages

| Page | Purpose |
|------|---------|
| Login/Signup | User authentication |
| Dashboard | Role-based home screen |
| Menu | Browse food items by category |
| Food Detail | View item info, add to cart |
| Cart | Review items, adjust quantities |
| Order Confirmation | Confirm and place order |
| Order History | View past orders, track status |
| Vendor Dashboard | View/manage incoming orders |
| Menu Management | Add/edit food items |
| Admin Panel | Manage users and view analytics |

### Order Status Lifecycle

```
Pending → Accepted → Preparing → Ready → Delivered
    ↓         ↓          ↓         ↓
 Cancelled  (Vendor)  (Vendor)  (Customer)
```

---

## Phase 1: Authentication & Profile (COMPLETED)
- [x] Email/Password Login
- [x] Email/Password Signup
- [x] Role selection (Customer/Vendor) during signup
- [x] Vendor approval workflow (is_approved flag)
- [x] Vendor login blocked until approved
- [x] Admin dashboard with vendor approval page
- [x] User Profile Management
- [x] Database schema (profiles table with RLS, role column, is_approved)
- [x] Basic Dashboard (role-based routing)

### Remaining
- [ ] Password Reset

---

## Phase 2: Core Food Ordering System

### 2.1 Food Menu & Categories
- [x] Create `categories` table in Supabase
- [x] Create `food_items` table in Supabase
- [x] Menu listing page with category filtering
- [x] Food item detail page
- [ ] Category management (Admin/Vendor)

### 2.2 Search Functionality
- [x] Search bar on menu page
- [x] Search by food name, category
- [x] Search results page

### 2.3 Cart System
- [x] Cart state management (Provider/Riverpod)
- [x] Add to cart functionality
- [x] Cart page with item list
- [x] Quantity update/remove items
- [x] Cart total calculation

### 2.4 Order Placement
- [x] Order confirmation page
- [x] Delivery address input
- [x] Order summary
- [x] Create `orders` table in Supabase
- [x] Create `order_items` table in Supabase
- [x] Insert order to database
- [x] Order placement confirmation

### 2.5 Order History
- [x] Order history page for customers
- [x] Order status display (Pending, Preparing, Ready, Delivered, Cancelled)
- [x] Order details view

---

## Phase 3: Vendor Features

### 3.1 Vendor Dashboard
- [x] Vendor authentication check
- [x] Vendor dashboard page
- [x] View incoming orders
- [x] Order status update (Accept, Prepare, Mark Ready)

### 3.2 Menu Management
- [x] Add new food item
- [x] Edit existing food item
- [x] Delete food item
- [x] Toggle item availability

---

<!-- let's ignore the admin feature for now 
## Phase 4: Admin Features

### 4.1 Admin Panel
- [x] Admin authentication check (via role-based routing)
- [x] Admin dashboard page
- [x] View pending vendor approvals
- [ ] Approve/reject vendor accounts
- [ ] View all users (Customers, Vendors)
- [ ] View all orders
- [ ] Order analytics overview

### 4.2 User Management
- [ ] Assign/change user roles
- [ ] View user details
- [ ] Disable/enable users -->

---

## Phase 5: Polish & UX

### 5.1 UI/UX Improvements
- [x] App icon and splash screen
- [x] Bottom navigation bar
- [x] Loading states and indicators
- [x] Error handling and snackbars
- [x] Empty states

### 5.2 Settings & Profile
- [ ] Profile picture upload (Supabase Storage)
- [x] Edit profile
- [ ] App settings page
- [ ] Logout functionality

---

## Database Schema Additions

```sql
-- Profiles (updated with role)
create table profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  phone text,
  department text,
  bio text,
  avatar_url text,
  role text not null default 'customer',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Categories
create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  image_url text,
  created_at timestamptz default now()
);

-- Food Items
create table food_items (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references categories(id),
  vendor_id uuid references auth.users(id),
  name text not null,
  description text,
  price decimal not null,
  image_url text,
  is_available boolean default true,
  created_at timestamptz default now()
);

-- Orders
create table orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references auth.users(id),
  status text default 'pending',
  total_amount decimal,
  delivery_address text,
  created_at timestamptz default now()
);

-- Order Items
create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id),
  food_item_id uuid references food_items(id),
  quantity int,
  price_at_order decimal
);
```

---

## Tech Stack
- **Frontend**: Flutter
- **Backend**: Supabase (Auth, Database, Storage)
- **State Management**: Riverpod (recommended)
- **Architecture**: Feature-based Clean Architecture

---

## File Structure
```
lib/
├── app/
│   ├── app.dart
│   └── theme/
├── core/
│   ├── constants/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   │   └── presentation/
│   ├── profile/
│   │   └── presentation/
│   ├── menu/
│   │   └── presentation/
│   ├── cart/
│   │   └── presentation/
│   ├── orders/
│   │   └── presentation/
│   ├── vendor/
│   │   └── presentation/
│   └── admin/
│       └── presentation/
└── main.dart
```
