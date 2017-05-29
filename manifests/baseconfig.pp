# This class ensures that all baseconfiguration are brought in.
class profile::baseconfig {
  include ::profile::baseconfig::puppet
  include ::profile::baseconfig::packages
}
