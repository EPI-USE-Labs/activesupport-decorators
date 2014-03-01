ActiveSupport Decorators
========================

The decorator pattern is particularly useful when extending constants in rails engines or vice versa.  To implement
the decorator pattern, you need to load the decorator after the original file has been loaded.  When you reference a
class in a Rails application, ActiveSupport will only load the first file it finds that matches the class name.  This
means that you will need to manually load the additional (decorator) file.  Usually you don't want to want to introduce
hard dependencies such as require statements.  You also don't want to preload a bunch of classes in a Rails initializer.
This is a tiny gem that provides you with a simple way to specify load file dependencies.

### Installation

Add it to your Gemfile and run bundle install:

```Ruby
gem 'activesupport-decorators', '~> 1.0'
```

#### Example 1 - Engine extends application class.

Your main rails application defines a model called Pet (in app/models/pet.rb):

```Ruby
class Pet < ActiveRecord::Base
end
```

Your rails engine adds the concept of pet owners to the application.  You extend the Pet model in the engine with
the following model decorator (in my_engine/app/models/pet_decorator.rb).

```Ruby
Pet.class_eval do
  belongs_to :owner
end
```

Now tell ActiveSupportDecorators to load any matching decorator file in my_engine/app when a file is loaded from
app/.  A convenient place to do this is in a Rails initializer in the engine:

```Ruby
module MyEngine
  module Rails
    class Engine < ::Rails::Engine
      initializer :set_decorator_dependencies do |app|
        ActiveSupportDecorators.add("#{app.root}/app", "#{config.root}/app")
      end
    end
  end
end
```

#### Example 2 - Application extends engine class.

Similar to the example above except the initializer is placed in the main application instead of the engine.  Create a
file called config/initializers/set_decorator_dependencies.rb (or any other name) with content:

```Ruby
ActiveSupportDecorators.add("#{MyEngine::Rails::Engine.root}/app", "#{Rails.root}/app")
```

#### Example 3 - Engine extends another engine class.

```Ruby
module MyEngine
  module Rails
    class Engine < ::Rails::Engine
      initializer :set_decorator_dependencies do |app|
        ActiveSupportDecorators.add("#{AnotherEngine::Rails::Engine.root}/app", "#{MyEngine::Rails::Engine.root}/app")
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

### Custom decorator file pattern

By default decorator files are matched with '_decorator' appended to the file name.  You can remove this suffix
completely or use your own one.  Note the method signature of add:

```Ruby
ActiveSupportDecorators.add(path, decorator_path, file_pattern = '_decorator')
```

### Decorating decorators

Nested decorators are supported.  Just set them to decorate a path where the dependant decorators are placed.

### Comparison to other gems

This is yet another decorator gem because it:
* allows you to specify where and how you name decorators.
* allows you to limit the paths you decorate.
* other gems tend to eager load as seen [here]
  (https://github.com/atd/rails_engine_decorators/blob/master/lib/rails_engine_decorators/engine/configuration.rb)
  and [here](https://github.com/parndt/decorators/blob/master/lib/decorators/railtie.rb).
* other gems assume you use 'MyClass.class_eval' to define decorators since it is how you trigger activesupport to load
  the original file.  This gem allows you to use the normal 'class MyClass' which means you can define constants in
  decorators.

However if you do not want to specify which path's you allow to be decorated, you should use another gem.  Instead of
single file look ups it will need to search your decorator directories for a matching file, which is not feasible
especially in a context where any ruby file may be decorated.  The best solution for such a scenario would be to
eager load the decorators like other gems do.