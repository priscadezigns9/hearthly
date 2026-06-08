-- Hearthly Supabase Schema

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Cooks Table
-- cooks (id, user_id, name, bio, city, cuisine_types, rating, review_count, is_verified)
CREATE TABLE cooks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  bio TEXT,
  city TEXT NOT NULL,
  cuisine_types TEXT[], -- Array of strings
  rating DECIMAL DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Meals Table
-- meals (id, cook_id, name, description, cuisine, price, portions_available, dietary_tags, image_label, is_active)
CREATE TABLE meals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cook_id UUID REFERENCES cooks(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  cuisine TEXT,
  price DECIMAL NOT NULL,
  portions_available INTEGER NOT NULL,
  dietary_tags TEXT[],
  image_label TEXT DEFAULT 'Primary food photo — real image required',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Orders Table
-- orders (id, meal_id, buyer_id, cook_id, quantity, total_price, status, created_at)
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  meal_id UUID REFERENCES meals(id),
  buyer_id UUID NOT NULL,
  cook_id UUID REFERENCES cooks(id),
  quantity INTEGER NOT NULL,
  total_price DECIMAL NOT NULL,
  status TEXT DEFAULT 'pending', -- 'pending', 'confirmed', 'completed', 'cancelled'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Reviews Table
-- reviews (id, order_id, cook_id, buyer_id, rating, comment, created_at)
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  cook_id UUID REFERENCES cooks(id) ON DELETE CASCADE,
  buyer_id UUID NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security (RLS) - Example Policies
ALTER TABLE cooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Public Read access for cooks and meals
CREATE POLICY "Public read cooks" ON cooks FOR SELECT USING (true);
CREATE POLICY "Public read meals" ON meals FOR SELECT USING (true);

-- Authenticated Insert/Update for cooks (only own record)
CREATE POLICY "Cooks can manage their own profile" ON cooks 
  FOR ALL USING (auth.uid() = user_id);

-- Meals management for cooks
CREATE POLICY "Cooks can manage their own meals" ON meals 
  FOR ALL USING (cook_id IN (SELECT id FROM cooks WHERE user_id = auth.uid()));

-- Orders management
CREATE POLICY "Buyers can see their own orders" ON orders 
  FOR SELECT USING (auth.uid() = buyer_id);
CREATE POLICY "Cooks can see orders for their meals" ON orders 
  FOR SELECT USING (cook_id IN (SELECT id FROM cooks WHERE user_id = auth.uid()));
CREATE POLICY "Buyers can create orders" ON orders 
  FOR INSERT WITH CHECK (auth.uid() = buyer_id);
CREATE POLICY "Cooks can update order status" ON orders 
  FOR UPDATE USING (cook_id IN (SELECT id FROM cooks WHERE user_id = auth.uid()));
