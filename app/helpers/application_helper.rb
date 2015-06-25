module ApplicationHelper
  def link_to_add_fields1(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render("questions/sample_fields", f: builder)
    end
    link_to(name, '#', class: "add_sample_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
  def link_to_add_fields2(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render("questions/testdata_fields", f: builder)
    end
    link_to(name, '#', class: "add_testdata_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
