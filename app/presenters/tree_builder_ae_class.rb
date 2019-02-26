class TreeBuilderAeClass < TreeBuilder
  has_kids_for MiqAeClass, %i(x_get_tree_class_kids type)
  has_kids_for MiqAeNamespace, %i(x_get_tree_ns_kids type)

  private

  def tree_init_options(_tree_name)
    {}
  end

  def set_locals_for_render
    locals = super
    locals.merge!(:autoload => true)
  end

  def root_options
    {
      :text    => t = _("Datastore"),
      :tooltip => t
    }
  end

  # Get root nodes count/array for explorer tree
  def x_get_tree_roots(count_only, _options)
    objects = if MiqAeClassController::MIQ_AE_COPY_ACTIONS.include?(@sb[:action])
                [MiqAeDomain.find_by(:id => @sb[:domain_id])] # GIT support can't use where
              else
                filter_ae_objects(User.current_tenant.visible_domains)
              end
    count_only_or_objects(count_only, objects)
  end

  def x_get_tree_class_kids(object, count_only, type)
    instances = count_only_or_objects(count_only, object.ae_instances, %i(display_name name))
    # show methods in automate explorer tree
    if type == :ae # FIXME: is this ever false?
      methods = count_only_or_objects(count_only, object.ae_methods, %i(display_name name))
      instances + methods
    else
      instances
    end
  end

  def x_get_tree_ns_kids(object, count_only, type)
    if type == :automate
      if object.respond_to?(:ae_namespaces) && filter_ae_objects(object.ae_namespaces).size == 1
        open_node("aen-#{object.id}")
        open_node("aen-#{object.ae_namespaces.first.id}")
      end

      if object.respond_to?(:ae_classes) && filter_ae_objects(object.ae_classes).size == 1
        open_node("aen-#{object.id}")
        open_node("aec-#{object.ae_classes.first.id}")
      end
    end
    objects = filter_ae_objects(object.ae_namespaces)
    unless MiqAeClassController::MIQ_AE_COPY_ACTIONS.include?(@sb[:action])
      ns_classes = filter_ae_objects(object.ae_classes)
      objects += ns_classes if ns_classes.present?
    end
    count_only_or_objects(count_only, objects, %i(display_name name))
  end

  def filter_ae_objects(objects)
    return objects unless @sb[:cached_waypoint_ids]
    klass_name = objects.first.class.name
    prefix = klass_name == "MiqAeDomain" ? "MiqAeNamespace" : klass_name
    objects.select { |obj| @sb[:cached_waypoint_ids].include?("#{prefix}::#{obj.id}") }
  end
end
