# frozen_string_literal: true

require "definition/v1_deprecator"

module Definition
  module Dsl
    module Comparators
      # Example:
      # MaxSize(5)
      def MaxSize(max_size) # rubocop:disable Naming/MethodName
        Types::Lambda.new(:max_size, context: { max_size: max_size }) do |value|
          case value
          when String, Enumerable
            conform_with(value) if value.size <= max_size
          else
            value
          end
        end
      end

      # Example:
      # MinSize(5)
      def MinSize(min_size) # rubocop:disable Naming/MethodName
        Types::Lambda.new(:min_size, context: { min_size: min_size }) do |value|
          case value
          when String, Enumerable
            conform_with(value) if value.size >= min_size
          else
            value
          end
        end
      end

      # Example:
      # NonEmptyString
      def NonEmptyString # rubocop:disable Naming/MethodName
        Types::And.new(:non_empty_string, Type(String), MinSize(1))
      end

      # Example:
      # GreaterThan(5)
      def GreaterThan(min_value) # rubocop:disable Naming/MethodName
        Types::Lambda.new("greater_than", context: { min_value: min_value }) do |value|
          conform_with(value) if value.is_a?(Numeric) && value > min_value
        end
      end
      alias GreaterThen GreaterThan
      deprecate :GreaterThen, deprecator: V1Deprecator

      # Example:
      # GreaterThanEqual(5)
      def GreaterThanEqual(min_value) # rubocop:disable Naming/MethodName
        Types::Lambda.new("greater_than_equal", context: { min_value: min_value }) do |value|
          conform_with(value) if value.is_a?(Numeric) && value >= min_value
        end
      end
      alias GreaterThenEqual GreaterThanEqual
      deprecate :GreaterThenEqual, deprecator: V1Deprecator

      # Example:
      # LessThan(5)
      def LessThan(max_value) # rubocop:disable Naming/MethodName
        Types::Lambda.new("less_than", context: { max_value: max_value }) do |value|
          conform_with(value) if value.is_a?(Numeric) && value < max_value
        end
      end
      alias LessThen LessThan
      deprecate :LessThen, deprecator: V1Deprecator

      # Example:
      # LessThanEqual(5)
      def LessThanEqual(max_value) # rubocop:disable Naming/MethodName
        Types::Lambda.new("less_than_equal", context: { max_value: max_value }) do |value|
          conform_with(value) if value.is_a?(Numeric) && value <= max_value
        end
      end
      alias LessThenEqual LessThanEqual
      deprecate :LessThenEqual, deprecator: V1Deprecator

      # Example:
      # Equal("value")
      def Equal(expected_value) # rubocop:disable Naming/MethodName
        Types::Lambda.new(:equal, context: { expected_value: expected_value }) do |value|
          conform_with(value) if value == expected_value
        end
      end

      # Example:
      # Empty
      def Empty # rubocop:disable Naming/MethodName
        Types::Lambda.new(:empty) do |value|
          case value
          when String, Array, Hash
            conform_with(value) if value.empty?
          else
            value
          end
        end
      end

      # Example:
      # NonEmpty
      def NonEmpty # rubocop:disable Naming/MethodName
        Types::Lambda.new(:non_empty) do |value|
          case value
          when String, Array, Hash
            conform_with(value) unless value.empty?
          else
            value
          end
        end
      end

      # Example:
      # Regex
      def Regex(regex, name: :regex) # rubocop:disable Naming/MethodName
        Types::Lambda.new(name, context: { regex: regex.inspect }) do |value|
          case value
          when String
            conform_with(value) unless regex.match(value).nil?
          else
            value
          end
        end
      end
    end
  end
end
