class TreeBuilderRegion < TreeBuilder
  has_kids_for MiqRegion, [:x_get_tree_region_kids]

  private

  def tree_init_options
    {:add_root => MiqEnterprise.my_enterprise.is_enterprise?}
  end

  def set_locals_for_render
    locals = super
    locals.merge!(:autoload => true)
  end

  # Get root nodes count/array for explorer tree
  def x_get_tree_roots(count_only, _options)
    ent = MiqEnterprise.my_enterprise
    objects = ent.miq_regions.sort_by { |a| a.description.downcase }
    count_only_or_objects(count_only, objects)
  end

  def x_get_tree_region_kids(object, count_only)
    emstype = if %i(bottlenecks utilization).include?(@type)
                object.ems_infras
              else
                object.ext_management_systems
              end
    emses = Rbac.filtered(emstype)
    storages = Rbac.filtered(object.storages)
    if count_only
      emses.count + storages.count
    else
      objects = []
      if emses.count.positive?
        objects.push(:id   => "folder_e_xx-#{object.id}",
                     :text => _("Providers"),
                     :icon => "pficon pficon-folder-close",
                     :tip  => _("Providers (Click to open)"))
      end
      if storages.count.positive?
        objects.push(:id   => "folder_ds_xx-#{object.id}",
                     :text => _("Datastores"),
                     :icon => "pficon pficon-folder-close",
                     :tip  => _("Datastores (Click to open)"))
      end
      objects
    end
  end

  def x_get_tree_custom_kids(object, count_only, _options)
    nodes = object[:id].split('_')
    id = nodes.last.split('-').last
    if object_ems?(nodes, object)
      rec = MiqRegion.find_by(:id => id)
      objects = rbac_filtered_sorted_objects(rec.ems_infras, "name")
      count_only_or_objects(count_only, objects)
    elsif object_ds?(nodes, object)
      rec = MiqRegion.find_by(:id => id)
      objects = rbac_filtered_sorted_objects(rec.storages, "name")
      count_only_or_objects(count_only, objects)
    elsif object_cluster?(nodes, object)
      rec = ExtManagementSystem.find_by(:id => id)
      objects = rbac_filtered_sorted_objects(rec.ems_clusters, "name") +
                rbac_filtered_sorted_objects(rec.non_clustered_hosts, "name")
      count_only_or_objects(count_only, objects)
    end
  end

  def object_ems?(nodes, object)
    (nodes.length > 1 && nodes[1] == "e") ||
      (object[:full_id] && object[:full_id].split('_')[1] == "e")
  end

  def object_ds?(nodes, object)
    (nodes.length > 1 && nodes[1] == "ds") ||
      (object[:full_id] && object[:full_id].split('_')[1] == "ds")
  end

  def object_cluster?(nodes, object)
    (nodes.length > 1 && nodes[1] == "c") ||
      (object[:full_id] && object[:full_id].split('_')[1] == "c")
  end

  def rbac_filtered_sorted_objects(records, sort_by, options = {})
    Rbac.filtered(records, options).sort_by { |o| o.deep_send(sort_by).to_s.downcase }
  end
end