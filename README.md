Flexible Accessibility

A simple library for setting access rules, based on analysis of current resources (e.g. controllers (with namespaces) and actions) that exists in application.

Installation:

		gem install flexible_accessibility

  or add to your Gemfile

		gem 'flexible_accessibility', '0.3.3'

  then do

        rails g flexible_accessibility:install

  to install migrations

Usage:

  All routes in application are closed by default
  To add route for check or open it you have to use 'authorize' macro in your controller
  The macro has a couple of options:

  Add all routes to check:

        authorize :all

  Add some routes to check but close all others

        authorize :only => [:index, :new]

  Add all routes except :index to check, :index remains closed

        authorize :except => [:index]

  Add :index and :new to check, skip (open) create for all

        authorize :only => [:index, :new], :skip => [:create]

  Open all routes for all

        authorize :skip => :all

======================

## Copyright
Copyright (c) 2012-2014 Sergey Avanesov and 7 Pikes, Inc.

![7pikes logo](https://github.com/7Pikes/flexible_accessibility/wiki/Logo.png)
