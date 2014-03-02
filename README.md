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

### Comparison to other gems

Other gems work by simply telling Rails to eager load all your decorators on application startup as seen [here]
(https://github.com/atd/rails_engine_decorators/blob/master/lib/rails_engine_decorators/engine/configuration.rb) and
[here](https://github.com/parndt/decorators/blob/master/lib/decorators/railtie.rb).  They expect your decorators to use
'MyClass.class_eval do' to extend the original class as this is what triggers the original class to be loaded.
Disadvantages of this approach include:
* decorators may not expect other classes to be decorated already, it's a bad idea to depend on load order.
* development mode is a bit slower since your eager decorator loading usually has a cascade effect on the application.
  This is more noticable when using JRuby as it will be a compile action instead of class load action.
* using 'MyClass.class_eval do' instead of 'class MyClass' means you can not define constants.

This gem works by hooking into ActiveSupport, which means that decorators are loaded as required instead of at
application startup.  You can use 'class MyClass' and expect that other classes are already decorated, since when you
reference other classes they will be decorated on the fly when ActiveSupport loads them.