/**
 * Hearthly - Shared Application Logic
 * Supabase Integration & Core Features
 */

// Initialize Supabase (User needs to replace these with their own project values)
const SUPABASE_URL = 'https://your-project-url.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';

// Mocking the supabase client for the sake of the template structure
// In a real app, you'd use: const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
const supabase = typeof supabase !== 'undefined' ? supabase : {
    auth: {
        getUser: async () => ({ data: { user: { id: 'mock-user-id' } }, error: null }),
        signIn: async () => {},
        signOut: async () => {}
    },
    from: (table) => ({
        select: () => ({
            eq: () => ({ data: [], error: null }),
            match: () => ({ data: [], error: null }),
            order: () => ({ data: [], error: null }),
        }),
        insert: () => ({ data: [], error: null }),
        update: () => ({ eq: () => ({ data: [], error: null }) }),
    })
};

// --- AUTH UTILS ---
async function getCurrentUser() {
    const { data: { user }, error } = await supabase.auth.getUser();
    return user;
}

// --- COOK UTILS ---
async function getCookProfile(userId) {
    const { data, error } = await supabase.from('cooks').select('*').eq('user_id', userId).single();
    return data;
}

async function registerCook(profileData) {
    const user = await getCurrentUser();
    const { data, error } = await supabase.from('cooks').insert([
        { ...profileData, user_id: user.id }
    ]);
    return { data, error };
}

// --- MEAL UTILS ---
async function fetchMeals(filters = {}) {
    let query = supabase.from('meals').select('*, cooks(*)').eq('is_active', true);
    
    if (filters.city) query = query.eq('cooks.city', filters.city);
    if (filters.cuisine) query = query.eq('cuisine', filters.cuisine);
    
    const { data, error } = await query;
    return data;
}

async function createMealListing(mealData) {
    const user = await getCurrentUser();
    const cook = await getCookProfile(user.id);
    if (!cook) throw new Error("Must be a registered cook");

    const { data, error } = await supabase.from('meals').insert([
        { ...mealData, cook_id: cook.id }
    ]);
    return { data, error };
}

// --- ORDER UTILS ---
async function placeOrder(mealId, cookId, quantity, unitPrice) {
    const user = await getCurrentUser();
    const totalPrice = quantity * unitPrice;
    
    const { data, error } = await supabase.from('orders').insert([
        {
            meal_id: mealId,
            buyer_id: user.id,
            cook_id: cookId,
            quantity: quantity,
            total_price: totalPrice,
            status: 'pending'
        }
    ]);
    
    if (!error) {
        // Show payment instructions since no Stripe
        showPaymentInstructions(totalPrice);
    }
    return { data, error };
}

function showPaymentInstructions(amount) {
    const commission = amount * 0.10;
    const cookPay = amount * 0.90;
    
    const instructions = `
        ORDER REQUESTED!
        
        Payment Details:
        Total: $${amount.toFixed(2)}
        
        To confirm your order, please pay via:
        1. PayPal: payments@hearthly.com (Send $${amount.toFixed(2)})
        2. Crypto (ERC-20): 0xcef857e82c306b3d0f2db080e7794f4bb376049e
        3. Payoneer: billing@hearthly.com
        
        Note: Hearthly takes a 10% commission. The cook will receive $${cookPay.toFixed(2)} once confirmed.
    `;
    alert(instructions);
}

async function updateOrderStatus(orderId, newStatus) {
    const { data, error } = await supabase.from('orders')
        .update({ status: newStatus })
        .eq('id', orderId);
    return { data, error };
}

// --- UI HELPERS ---
function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
}

// Export for use in other files
window.Hearthly = {
    getCurrentUser,
    getCookProfile,
    registerCook,
    fetchMeals,
    createMealListing,
    placeOrder,
    updateOrderStatus,
    formatCurrency
};
