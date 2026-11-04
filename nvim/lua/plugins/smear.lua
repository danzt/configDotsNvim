return {
  "sphamba/smear-cursor.nvim",
  opts = {
    -- Auto-desactiva el smear si la animación queda trabada (típico bajo
    -- multiplexores como Zellij/tmux, donde deja "basura" en pantalla).
    delay_disable = 300,
  },
}
