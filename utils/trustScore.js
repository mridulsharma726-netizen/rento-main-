const { supabase } = require('../config/supabase');

const IMPACTS = {
    'BOOKING_COMPLETED': 10,
    'GOOD_RATING': 5,
    'KYC_VERIFIED': 20,
    'BOOKING_CANCELLED': -10,
    'COMPLAINT': -20
};

/**
 * Updates a user's trust score based on an action.
 */
async function updateTrustScore(userId, action, referenceId = null) {
    try {
        const scoreChange = IMPACTS[action];
        if (!scoreChange) return;

        // Check for duplicate update
        if (referenceId) {
            const { data: existingLog } = await supabase
                .from('trust_logs')
                .select('id')
                .match({ user_id: userId, action, reference_id: referenceId })
                .maybeSingle();
            
            if (existingLog) return; 
        }

        const { data: user, error: userError } = await supabase
            .from('users')
            .select('*')
            .eq('id', userId)
            .single();

        if (userError || !user) return;

        let newScore = Math.max(0, Math.min(100, (user.trust_score || 20) + scoreChange));

        const updates = { 
            trust_score: newScore,
            updated_at: new Date().toISOString()
        };
        
        if (action === 'BOOKING_COMPLETED') {
            updates.completed_transactions = (user.completed_transactions || 0) + 1;
            updates.total_transactions = (user.total_transactions || 0) + 1;
        } else if (action === 'BOOKING_CANCELLED') {
            updates.cancelled_transactions = (user.cancelled_transactions || 0) + 1;
            updates.total_transactions = (user.total_transactions || 0) + 1;
        } else if (action === 'KYC_VERIFIED') {
            updates.is_kyc_verified = true;
        }

        const { error: updateError } = await supabase
            .from('users')
            .update(updates)
            .eq('id', userId);

        if (updateError) throw updateError;

        await supabase.from('trust_logs').insert([{
            user_id: userId,
            action,
            score_change: scoreChange,
            reference_id: referenceId
        }]);

        console.log(`✅ Trust Score Updated: ${userId} -> ${newScore}`);
    } catch (error) {
        console.error('❌ Error updating trust score:', error);
    }
}

module.exports = { updateTrustScore };
