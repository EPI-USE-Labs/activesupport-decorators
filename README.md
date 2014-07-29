ActiveSupport Decorators
========================

[![Build Status](https://travis-ci.org/pierre-pretorius/activesupport-decorators.png?branch=master)]
(https://travis-ci.org/pierre-pretorius/activesupport-decorators)

The decorator pattern is particularly useful when extending constants in rails engines or vice versa.  To implement
the decorator pattern, you need to load the decorator after the original file has been loaded.  When you reference a
class in a Rails application, ActiveSupport will only load the first file it finds that matches the class name.  This
means that you need to manually load the additional (decorator) file or eager load all of them on application startup.
This is a tiny gem that provides you with a simple way to tell ActiveSupport to load your decorator files when needed.

### Installation

Add it to your Gemfile and run bundle install:

```Ruby
gem 'activesupport-decorators', '~> 2.0'
```

### Usage

#### Example 1 - Application extends engine (or any other) class.

Your Rails engine defines a model called Pet (in my_engine/app/models/pet.rb):

```Ruby
class Pet < ActiveRecord::Base
end
```

Your Rails application now wants to adds the concept of pet owners.  You extend the Pet model in the main application
with the following model decorator (in app/models/pet_decorator.rb).  Note that you could use 'Pet.class_eval do'
instead of 'class Pet' if you want.

```Ruby
class Pet
  belongs_to :owner
end
```

Set your ActiveSupportDecorators paths similar to setting Rails autoload paths.  This will load a decorator file if it
matches the original file's name/path and ends with '_decorator.rb'.  In other words when the engine's app/pet.rb is
loaded, it will load the main applications app/pet_decorator.rb.

```Ruby
ActiveSupportDecorators.paths << File.join(Rails.application.root, 'app/**')
```

Note that '**' is added to the end of the path because this is the pattern that Rails autoloads your app folder with.
It means that every folder inside app is regarded as a autoload path instead of app/ itself, so that you can call your
model 'Pet' and not 'Models::Pet'.

#### Example 2 - Engine extends application (or any other) class.

Similar to the example above except the initializer is placed in the engine instead of the main application. The example
below will cause any matching decorator file in my_engine/app to load when a file is loaded from app/.

```Ruby
module MyEngine
  module Rails
    class Engine < ::Rails::Engine
      initializer :set_decorator_paths, :before => :load_environment_hook do |app|
        ActiveSupportDecorators.paths << File.join(config.root, 'app/**')
      end
    end
  end
end
```

### Debugging

Need to know which decorator files are loaded?  Enable debug output:

```Ruby
ActiveSupportDecorators.debug = true
```

### Comparison to other gems

Other gems work by simply telling Rails to eager load all your decorators on application startup as seen [here]
(https://github.com/atd/rails_engine_decorators/blob/master/lib/rails_engine_decorators/engine/configuration.rb) and
[here](https://github.com/parndt/decorators/blob/master/lib/decorators/railtie.rb).  They expect your decorators to use
'MyClass.class_eval do' to extend the original class as this is what triggers the original class to be loaded.
Disadvantages of this approach include:
* if you decorate two classes and one uses decorated functionality of the other, you have to make sure that it is not
  used during class loading since the other class might not be decorated yet.
* development mode is a bit slower since eager loading decorators usually has a cascade effect on the application.
  This is more noticeable when using JRuby as it will be a compile action instead of class load action.
* using 'MyClass.class_eval do' instead of 'class MyClass' means you can not define constants.

This gem works by hooking into ActiveSupport, which means that decorators are loaded as required instead of at
application startup.  You can use 'class MyClass' and expect that other classes are already decorated, since when you
reference other classes they will be decorated on the fly when ActiveSupport loads them.
