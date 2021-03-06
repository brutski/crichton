require 'crichton/descriptor/base'

module Crichton
  module Descriptor
    # Manages transitions defined for states. 
    #
    class StateTransition < Base
      ## 
      # The condition options that indicate a transition should be included in a response that represents the
      # associated state of a resource.
      #
      # @return [Array] The conditions.
      def conditions
        @descriptors[:conditions] ||= (descriptor_document['conditions'] || [])
      end

      ##
      # @!attribute [r] next
      # The next states that are possible if the transition is executed. 
      #
      # This will either be a single state or possibly the error state and a success state. Used to generate
      # state machine diagrams associated with resources.
      #
      # @return [Array] The next state(s).
      def next
        @descriptors[:next] ||= (descriptor_document['next'] || [])
      end

      ##
      # Whether the transition is available for the specified options.
      #
      # @param [Hash] options Conditional options.
      # @option options [Hash, String, Symbol] :conditions The conditions to validate against the transition conditions.
      # @return [Boolean] <tt>true</tt> if available, <tt>false</tt> otherwise.
      def available?(options = nil)
        return true if conditions.empty?

        option_conditions = Array.wrap(options[:conditions] || {})
        return false if option_conditions.empty?

        conditions.any? do |condition|
          option_conditions.any? do |option_condition|
            if condition.is_a?(Hash) && option_condition.is_a?(Hash)
              option_condition.keys.any? { |k| condition[k.to_s] == option_condition[k].to_s }
            elsif condition.is_a?(String)
              condition == option_condition.to_s
            end
          end
        end
      end
    end
  end
end

