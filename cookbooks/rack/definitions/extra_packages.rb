define :extra_packages, action: :install do
  if params[:action] == :install
    if params[:extra_packages]
      params[:extra_packages].split(',').map(&:strip).each do |pckg|
        package pckg do
          action :install
        end
      end
    end
  end
end