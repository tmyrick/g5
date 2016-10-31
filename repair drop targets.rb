def repair_drop_targets(html_id, widgets=[])
  bad = Website.all.select do |web|
    !web.website_template.blank? && (
    web.website_template.drop_targets.find_by_html_id(html_id).blank? ||
    web.website_template.drop_targets.find_by_html_id(html_id).widgets.blank?)
  end

  bad.each do |web|
    wt = web.website_template
    dt = wt.drop_targets.find_by_html_id(html_id)
    if dt.blank?
      dt = DropTarget.new({web_template: wt, html_id: html_id})
      dt.save
    end

    web.reload
    wt.reload
    l = web.owner

    widgets.each_with_index do |slug, idx|
      unless dt.widgets.any? { |widget| widget.name == slug }
        WidgetAdderJob.new.perform(l.id, html_id.gsub('drop-target-',''), slug, idx)
      end
    end
  end

  puts "#{bad.count} bad websites repaired: #{bad.map(&:name).join(', ')}"
end


then


repair_drop_targets("drop-target-footer", ['contact-info','footer-info','typekit'])