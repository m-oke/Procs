# Nested Form Fields [![Build Status](https://secure.travis-ci.org/ncri/nested_form_fields.png)](http://travis-ci.org/ncri/nested_form_fields)

This Rails gem helps creating forms for models with nested has_many associations.

It uses jQuery to dynamically add and remove nested associations.

- Works for arbitrarily deeply nested associations (tested up to 4 levels).
- Works with form builders like simple_form.
- Requires Ruby 1.9 and the Rails asset pipeline



## Installation

Add this line to your application's Gemfile:

    gem 'nested_form_fields'

And then execute:

    $ bundle

In your application.js file add:

    //= require nested_form_fields

## Usage

Assume you have a user model with nested videos:

    class User < ActiveRecord::Base
      has_many :videos
      accepts_nested_attributes_for :videos, allow_destroy: true
    end

Use the *nested_fields_for* helper inside your user form to add the video fields:

    = form_for @user do |f|
      = f.nested_fields_for :videos do |ff|
        = ff.text_field :video_title
        ..

Links to add and remove fields can be added using the *add_nested_fields_link* and *remove_nested_fields_link* helpers:

    = form_for @user do |f|
      = f.nested_fields_for :videos do |ff|
        = ff.remove_nested_fields_link
        = ff.text_field :video_title
        ..
      = f.add_nested_fields_link :videos

Note that *remove_nested_fields_link* needs to be called within the *nested_fields_for* call and *add_nested_fields_link* outside of it via the parent builder.

You can change the link text of *remove_nested_fields_link* and *add_nested_fields_link* like this:

    ...
      ff.remove_nested_fields_link 'Remove me'
      ...
    f.add_nested_fields_link :videos, 'Add another funtastic video'

You can add classes/attributes to the  *remove_nested_fields_link* and *add_nested_fields_link* like this:

    ...
      ff.remove_nested_fields_link 'Remove me', class: 'btn btn-danger', role: 'button'
      ...
    f.add_nested_fields_link :videos, 'Add another funtastic video', class: 'btn btn-primary', role: 'button'

You can change the type of the element wrapping the nested fields using the *wrapper_tag* option:

    = f.nested_fields_for :videos, wrapper_tag: :div do |ff|

The default wrapper element is a fieldset. To add legend element to the fieldset use:

    = f.nested_fields_for :videos, legend: "Video" do |ff|

You can pass options like you would to the `content_tag` method by nesting them in a `:wrapper_options` hash:

    = f.nested_fields_for :videos, wrapper_options: { class: 'row' } do |ff|

If you are using Rails 4 remember to add << NESTED_MODEL >>_attributes and the attributes to the permitted params. 
Also, if you want to destroy the nested model you should add :_destroy and :id.
For example:

    # app/views/users/_form.haml.erb
    = form_for @user do |f|
      = f.nested_fields_for :videos do |ff|
        = ff.remove_nested_fields_link
        = ff.text_field :video_title
        ..
      = f.add_nested_fields_link :videos
      
    # app/controllers/users_controller
    ..
    def user_params
        params.require(:user)
            .permit(:name,:email,videos_attributes:[:video_title,:_destroy,:id])
    #                            ^^^                 ^^^           ^^^
    #                            nested model attrs  
    #                                                             they will let you delete the nested model                    
    end


There are 4 javascipt events firing before and after addition/removal of the fields in the *nested_form_fields* namespace. Namely:
    fields_adding, fields_added, fields_removing, fields_removed.

The events fields_added and fields_removed are triggered on the element being added or removed. The events bubble up so you can listen for them on any parent element.
This makes it easy to add listeners when you have multiple nested_form_fields on the same page.

CoffeeScript samples:

    # Listen on an element
    initializeSortable -> ($el)
      $el.sortable(...)
      $el.on 'fields_added.nested_form_fields', -> (event, param)
        console.log event.target # The added field
        console.log $(this)      # $el

    # Listen on document
    $(document).on "fields_added.nested_form_fields", (event,param) ->
        switch param.object_class
            when "video"
                console.log "Video object added"
            else
                console.log "INFO: Fields were successfully added, callback not handled."


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Contributers

https://github.com/ncri/nested_form_fields/graphs/contributors
