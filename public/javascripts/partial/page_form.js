$('#page_organization_id').change(
  function(event) {
    var combo = $(event.target);
    var org_id = combo.val();
    //load the projects
    $.getJSON('/kurum/' + org_id + "/projeler", function(resp) {
      options_html = "";
      $(resp).each(function(index, project) {
        options_html += "<option value='" + project.id + "'>" + project.name  + "</option>";
      });
      $('#page_project_id').html(options_html);
    });
  }
  );