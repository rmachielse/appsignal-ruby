module Appsignal
  class Hooks
    class PassengerHook < Appsignal::Hooks::Hook
      register :passenger

      def dependencies_present?
        defined?(::PhusionPassenger)
      end

      def install
        ::PhusionPassenger.on_event(:starting_worker_process) do |forked|
          Appsignal.forked
        end

        ::PhusionPassenger.on_event(:stopping_worker_process) do
          Appsignal.stop
        end
      end
    end
  end
end