return {
	'rcarriga/nvim-notify',
	config = function ()
		require('notify').setup({
			  background_colour = "#000000",
			  opacity = 0.8,
			  position = "bottom",
		  })
	  end
  }
