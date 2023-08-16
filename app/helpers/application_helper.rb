module ApplicationHelper
    ALERT_TYPES = [:success, :info, :warning, :danger] unless const_defined?(:ALERT_TYPES)

    def bootstrap_flash(options = {})
        flash_messages = []
        flash.each do |type, message|

            # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
            next if message.blank?

            type = type.to_sym
            type = :success if type == :notice
            type = :danger  if type == :alert
            type = :danger  if type == :error
            next unless ALERT_TYPES.include?(type)

            tag_class = options.extract!(:class)[:class]
            tag_options = {
                class: "mt-2 alert alert-#{type} #{tag_class} alert-dismissible fade show"
            }.merge(options)
            
            close_button = content_tag(:button, "", type: "button", class: "btn-close", "data-bs-dismiss": "alert")

            p message if type = :error

            Array(message).each do |msg|
                text = content_tag(:div, close_button + msg, tag_options)
                flash_messages << text if msg
            end
        end
        flash_messages.join("\n").html_safe
    end

    def tenant_name(tenant_id)
       Tenant.find(tenant_id).name 
    end

    def s3_link(tenant_id, artifact_key)
        link_to artifact_key, "#{artifact_key}", class: 'main-link', target: 'new'
    end

    def class_name_for_tenant_form(tenant)
        return "cc_form" if tenant.payment.blank?
        ""
    end
end