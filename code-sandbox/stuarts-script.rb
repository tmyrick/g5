class PsOfShit
  require 'csv'

  def initialize(client_id)
    client = Client.find(1404)
    @path = "#{Rails.root}/ps_export_#{1404}.csv"
    @stores = client.stores
  end

  def export_numbers
    csv = build_csv(@stores)
    # download_csv
  end

  private

  def build_csv(stores)
    CSV.open(@path, "wb") do |csv|
      stores.each do |store|
        puts "Reading #{store.name}"
        store.services.each do |service|
          if service.type == "CallTrackingService"
            csv << ["#{store.name}", "#{service.tracking_number}", "#{service.cpm_codes}", "#{service.channel}", "#{service.name}"]
          end
        end
      end
    end
  end
end



### if client id is 1229
### scp demo:core_current/ps_export_1404.csv Desktop/
### PsOfShit.new(1229).export_numbers