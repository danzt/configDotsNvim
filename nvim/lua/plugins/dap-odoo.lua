-- Debug remoto de Odoo corriendo en Docker (odoo-lab) via debugpy.
-- El contenedor arranca con ODOO_DEBUGPY=1 escuchando en 0.0.0.0:5678
-- (ver /Users/danzt/Codes/odoo-lab/Dockerfile + docker-compose.yml).
-- Esto solo conecta nvim-dap a ese socket, no instala nada localmente.

local HOST_ROOTS = {
  { host = "/Users/danzt/Codes/Odoo/genios", container = "/opt/genios" },
  { host = "/Users/danzt/Codes/Odoo/reciclajesv", container = "/opt/reciclajesv" },
  { host = "/Users/danzt/Codes/Odoo/enterprise", container = "/opt/enterprise" },
  { host = "/Users/danzt/Codes/odoo-lab/addons", container = "/mnt/extra-addons" },
}

local last_db = "genios_prod" -- cambia a "reciclajesv" si estas en ese stack

-- Dado un path local, devuelve el modulo Odoo (primer directorio bajo el root que matchea)
local function module_from_path(path)
  for _, root in ipairs(HOST_ROOTS) do
    if path:sub(1, #root.host) == root.host then
      local rest = path:sub(#root.host + 2) -- +2: saltar la barra
      local module = rest:match("^([^/]+)")
      return module
    end
  end
  return nil
end

return {
  "mfussenegger/nvim-dap",
  optional = true,
  opts = function()
    local dap = require("dap")

    dap.adapters.python = dap.adapters.python
      or {
        type = "server",
        host = "127.0.0.1",
        port = 5678,
      }

    dap.configurations.python = dap.configurations.python or {}
    table.insert(dap.configurations.python, {
      type = "python",
      request = "attach",
      name = "Odoo (docker attach :5678)",
      connect = { host = "127.0.0.1", port = 5678 },
      pathMappings = vim.tbl_map(function(root)
        return { localRoot = root.host, remoteRoot = root.container }
      end, HOST_ROOTS),
      justMyCode = false,
    })
  end,
  keys = {
    {
      "<leader>dT",
      function()
        local module = module_from_path(vim.fn.expand("%:p")) or "<modulo>"
        vim.ui.input({ prompt = "Odoo test-tag: ", default = "/" .. module }, function(tag)
          if not tag or tag == "" then
            return
          end
          vim.ui.input({ prompt = "DB: ", default = last_db }, function(db)
            if not db or db == "" then
              return
            end
            last_db = db
            vim.fn.jobstart({
              "docker",
              "compose",
              "-f",
              "/Users/danzt/Codes/odoo-lab/docker-compose.yml",
              "exec",
              "-e",
              "ODOO_DEBUGPY=1",
              "-e",
              "ODOO_DEBUGPY_WAIT=1", -- pausa hasta que <leader>dc conecte, sin carrera
              "odoo",
              "odoo",
              "--test-enable",
              "--test-tags",
              tag,
              "--stop-after-init",
              -- --no-http no evita el bind del puerto 8069 (verificado); el
              -- proceso principal del contenedor ya lo tiene tomado, asi que
              -- usamos otro puerto para el proceso de test/debug.
              "--http-port=8070",
              "-d",
              db,
            }, {
              stdout_buffered = false,
              on_stdout = function(_, data)
                if data then
                  vim.schedule(function()
                    for _, line in ipairs(data) do
                      if line ~= "" then
                        vim.notify(line)
                      end
                    end
                  end)
                end
              end,
            })
            vim.notify("Corriendo " .. tag .. " con ODOO_DEBUGPY=1 — conecta con <leader>dc > Odoo (docker attach :5678)")
          end)
        end)
      end,
      desc = "Run Odoo test [T]",
    },
  },
}
