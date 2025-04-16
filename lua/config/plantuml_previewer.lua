-- PlantUML Previewer
--
-- Install plantuml with: make plantuml
-- Jar stored at: stdpath('data')/opt/plantuml/plantuml.jar
--
-- Commands:
--   :PlantumlOpen      open preview
--   :PlantumlStop      stop preview server
--   :PlantumlSave      save diagram to file
--
local jar_path = vim.fn.stdpath('data') .. '/opt/plantuml/plantuml.jar'

return {
    packages = {
        'weirongxu/plantuml-previewer.vim',
        'aklt/plantuml-syntax',
        'tyru/open-browser.vim',
    },
    setup = function()
        vim.api.nvim_set_var(
            'plantuml_previewer#plantuml_jar_path', jar_path)
    end
}
