
return """

<h3>Resources for <%= host.get("ip") %></h3>

<% if (resources.length == 0) { %>

  <p>No resources have been configured</p>

<%
} else {
  resources.each(function(resource) {
%>

<div class="resource">
  <h5 class="title">
    <!-- -#< %= resource.check.command.get("name") + ":" %> -->
    <%= resource.get("name") %>
  </h5>
  <div class="graph">
    <!-- -# - render_graph(resource) -->
  </div>
  <h6 class="footer">
    Last Value:
    n/a
  </h6>
</div>

<%
  });
}
%>

<br />
<p>
  <a class="btn primary add_resource_link" host_id="<%= host.get('id') %>">Add Resource</a>
</p>

"""