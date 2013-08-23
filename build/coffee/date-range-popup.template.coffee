template = """
<input type="text" />

<ul class="dropdown-menu date-range-popup">
  <li>
  <date-range-picker></date-range-picker>
  </li>
  <li class="divider"></li>
  <li class="clearfix" style="padding: 3px 9px;"><button class="close-popup btn btn-success btn-small pull-right">Close</button></li>
</ul>

"""
module = angular.module('powow.bootstrap.date-range.template.date-range-popup', [])

registerTemplate = ($templateCache) ->
  $templateCache.put('/src/date-range-popup.html', template)

module.run(['$templateCache', registerTemplate])
