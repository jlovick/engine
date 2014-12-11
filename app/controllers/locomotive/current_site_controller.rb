module Locomotive
  class CurrentSiteController < BaseController

    localized

    skip_load_and_authorize_resource

    load_and_authorize_resource class: 'Site'

    helper 'Locomotive::Sites'

    before_filter :filter_attributes

    before_filter :ensure_domains_list, only: :update

    respond_to :json, only: :update

    def edit
      @site = current_site
      respond_with @site
    end

    def update
      @site = current_site
      @site.update_attributes(params[:site])
      respond_with @site, location: edit_current_site_path(new_host_if_subdomain_changed)
    end

    def new_domain
      if params[:domain].present?
        render partial: 'domain', locals: { domain: params[:domain] }
      else
        head :unprocessable_entity
      end
    end

    def new_locale
      if params[:locale].present?
        render partial: 'locale', locals: { locale: params[:locale] }
      else
        head :unprocessable_entity
      end
    end

    protected

    def filter_attributes
      unless can?(:manage, Locomotive::Membership)
        params[:site].delete(:memberships_attributes) if params[:site]
      end
    end

    def new_host_if_subdomain_changed
      if !Locomotive.config.manage_subdomain? || @site.domains.include?(request.host)
        {}
      else
        { host: site_url(@site, { fullpath: false, protocol: false }) }
      end
    end

    def ensure_domains_list
      params[:site][:domains] = [] unless params[:site][:domains]
    end

  end
end