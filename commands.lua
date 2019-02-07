-- Command to show formspec for using exchange
minetest.register_chatcommand("exchange", {
    params = "",
    description = "Open the Exchange",
    func = function(name, params)
        exchange.show_formspec(name)
    end,
})
