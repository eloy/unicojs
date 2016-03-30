class IncludeBlankDirective
  link: (ctx, el, meta) ->
    blank = document.createElement("option")
    blank.text = "Select an option"
    blank.disabled = true
    blank.selected = true
    el.insertBefore(blank, el.firstChild);
UnicoApp.builtInDirectives ||= {}
UnicoApp.builtInDirectives['include-blank'] = IncludeBlankDirective
