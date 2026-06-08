# Hearthly - Home Chef Economy Marketplace

Hearthly is an "Airbnb for home-cooked food." It empowers home chefs to list their culinary creations and enables local buyers to discover and order authentic, homemade meals in their neighborhood.

An **Orcinos** Product.

## Features

- **Cook Profiles:** Register as a home chef, manage your bio, and set payout preferences.
- ** Meal Listings:** Create detailed listings with price, description, and available portions.
- ** Browse & Search:** Find food by city, cuisine, or dietary requirements.
- **Order Flow:** Request orders with clear payment instructions for non-Stripe gateways.
- **Cook Dashboard:** Manage incoming orders and track earnings.
- **Buyer Dashboard:** Review order history and leave feedback for chefs.
- ** Review System:** Build trust with star ratings and community comments.

## Tech Stack

- **Frontend:** HTML5, CSS3, Vanilla JavaScript.
- ** Backend:** Supabase (Auth, Database, RLS).
- ** Styling:** Custom "Warm & Homey" palette (Terracotta, Sage, Cream).

## Design Specification | Orcinos Gold Standard

- ** Color Palette:**
  - Terracotta: `#C4622A` (Primary CTA
  - Sage: `#4A7C5F` (Secondary Action)
  - Cream: `#FBF5E6` (Background)
  - Rich Brown: `#rc1a0e (Text/Accent)
- **Visuals:** Minimalist cards, high-fidelity spacing, and designated areas for primary food photography.

## Payment Flow (Non-Stripe)

Hearthly operates on a direct-to-chef model with platform commission:
1. **Platform Commission:** 10%
2. ** Chef Payout:** 90%
3. **Methods Supported:**
- **PayPal:** payments@hearthly.com
- **Crypto (ERC-20):** `0xcef857e82c306b3d0f2db080e7794f4bb376049e`
- **Payoneer:** billing@hearthly.com

## Setup Instructions

1. **Supabase Setup:**
   - Run the provided `schema.sql` in your Supabase SQL Editor.
   - Update `shared/app.js` with your Project URL and Anon Key.
2. **Deploy:**
   - Upload the `hearthly/` directory to any static hosting provider (Netlify, Vercel, GitHub Pages).


## Legal Notice

Hearthly is a marketplace connecting independent cooks and buyers. Users are responsible for adhering to local food safety and cottage food laws.
