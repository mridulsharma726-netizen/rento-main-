const { supabase } = require('../config/supabase');

/**
 * Logs a sensitive action for audit purposes
 */
const logAction = async ({ entity_type, entity_id, action, previous_value, new_value, performed_by, req = null, metadata = {} }) => {
    try {
        await supabase.from('audit_logs').insert([{
            entity_type,
            entity_id,
            action,
            previous_value,
            new_value,
            performed_by,
            ip_address: req ? req.ip : null,
            user_agent: req ? req.get('user-agent') : null,
            metadata
        }]);
    } catch (error) {
        console.error('⚠️ Audit Log Error:', error.message);
    }
};

module.exports = { logAction };
