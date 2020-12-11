# frozen_string_literal: true

require_relative 'join_keys'

# Monkey-patch Blueprinter::AssociationExtractor to use `batch-loader` gem in
# order to avoid n+1 queries when serializing associations.
#
# This does not support associations defined using a `proc` as
# `options[:blueprint]`
#
module Blueprinter
  class AssociationExtractor < Blueprinter::Extractor
    alias original_extract extract

    def extract(association_name, object, local_options, options = {})
      return original_extract(association_name, object, local_options, options) unless options.fetch(:batch, true)

      association = object.association(association_name)

      if association.is_a?(ActiveRecord::Associations::HasManyThroughAssociation)
        return original_extract(association_name, object, local_options, options)
      end

      raise 'Cannot load blueprints with a `proc` blueprint option with batch-loader' if options[:blueprint].is_a?(Proc)

      join_key = ::ApiBlocks::Blueprinter::JoinKeys.join_keys(association.reflection)

      association_id = object.send(join_key.foreign_key)
      association_klass = association.reflection.class_name

      default_value = case association
                      when ActiveRecord::Associations::HasManyAssociation
                        []
                      end

      view = options[:view] || :default
      scope = if options[:block].present?
                options[:block].call(object, local_options)
              else
                {}
              end

      BatchLoader.for(association_id).batch(
        default_value: default_value,
        key: [association_name, association_klass, view, options[:blueprint], scope]
      ) do |ids, loader, args|
        model = association_klass.safe_constantize
        scope = args[:key].last

        case association
        when ActiveRecord::Associations::HasManyAssociation
          model.where(join_key.key => ids).merge(scope).each do |record|
            loader.call(record.send(join_key.key)) do |memo|
              memo << render_blueprint(record, local_options, options)
            end
          end
        when ActiveRecord::Associations::HasOneAssociation
          model.where(join_key.key => ids).merge(scope).each do |record|
            loader.call(
              record.send(join_key.key),
              render_blueprint(record, local_options, options)
            )
          end
        when ActiveRecord::Associations::BelongsToAssociation
          model.where(join_key.key => ids).merge(scope).each do |record|
            loader.call(
              record.id,
              render_blueprint(record, local_options, options)
            )
          end
        else
          raise "unsupported association kind #{association.class.name}"
        end
      end
    end

    private

    def render_blueprint(value, local_options, options = {})
      return default_value(options) if value.nil?

      view = options[:view] || :default
      blueprint = association_blueprint(options[:blueprint], value)
      blueprint.prepare(value, view_name: view, local_options: local_options)
    end
  end
end
