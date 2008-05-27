module YARD
  module Generators
    class ConstantsGenerator < Base
      before_section :constants, :has_constants?
      before_section :inherited, :has_inherited_constants?
      before_section :included,  :has_included_constants?
      
      def sections_for(object) 
        if object.is_a?(CodeObjects::ClassObject)
          [:header, [:constants, :inherited, :included]] 
        elsif object.is_a?(CodeObjects::ModuleObject)
          [:header, [:constants]]
        end
      end

      protected
      
      def has_constants?(object)
        object.constants(:included => false, :inherited => false).size > 0
      end
      
      def has_inherited_constants?(object)
        object.inherited_constants.size > 0
      end
      
      def has_included_constants?(object)
        object.included_constants.size > 0
      end
        
      # @yield [superclass, constlist] 
      #   Yields a the list of methods pertaining to a superclass
      #   in the inheritance order.
      # 
      # @yieldparam [CodeObjects::ClassObject] superclass 
      #   The superclass the constants belong to
      # 
      # @yieldparam [Array<CodeObjects::ConstantObject>] consts
      #   The list of constants inherited from the superclass
      # 
      def inherited_constants_by_class
        all_consts = current_object.inherited_constants
        current_object.inheritance_tree[1..-1].each do |superclass|
          opts = { :included => false, :inherited => false }
          consts = superclass.constants(opts).select {|c| all_consts.include?(c) }
          next if consts.empty?
          yield(superclass, consts)
        end
      end

      # @yield [mixin, constlist] 
      #   Yields a the list of methods pertaining to a mixin
      #   in the mixin order.
      # 
      # @yieldparam [CodeObjects::ClassObject] mixin 
      #   The mixin the constants belong to
      # 
      # @yieldparam [Array<CodeObjects::ConstantObject>] consts
      #   The list of constants included from the mixin
      # 
      def included_constants_by_class
        all_consts = current_object.included_constants
        current_object.mixins.each do |superclass|
          opts = { :included => false, :inherited => false }
          consts = superclass.constants(opts).select {|c| all_consts.include?(c) }
          next if consts.empty?
          yield(superclass, consts)
        end
      end
    end
  end
end