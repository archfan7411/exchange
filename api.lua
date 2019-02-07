-- Exchange API by archfan711, licensed MIT
-- Written February 2019

-- Sale definitions are a table with the following fields:
-- item, the itemstring
-- price, the price in exchange.currency
-- seller, the player selling the item
-- wear (TBD), the amount of wear on the item or nil for a non-tool
-- stock (TBD), the number of units in stock for this particular offer

-- Creating the exchange
local storage = minetest.get_mod_storage()
exchange = {}
exchange.offers = minetest.deserialize(storage:get_string("data")) or {}
exchange.currency = minetest.deserialize(storage:get_string("currency")) or "default:gold_ingot"

function exchange.update_modstorage()
    storage:set_string("data", minetest.serialize(exchange.offers))
    storage:set_string("currency", minetest.serialize(exchange.currency))
end

-- Accepts sale definition to be registered
function exchange.register_offer(sale)
    -- Inserts sale and updates mod storage
    table.insert(exchange.offers, sale)
    exchange.offers = exchange.sort_by_increasing_price(exchange.offers)
    exchange.update_modstorage()
end

-- Accepts sale definition to be removed
function exchange.remove_offer(sale)
    -- Finds index of object to be removed
    for i, obj in ipairs(exchange.offers) do
        if obj == sale then
            -- Remove object
            exchange.offers.remove(i)
            exchange.offers = exchange.sort_by_increasing_price(exchange.offers)
            exchange.update_modstorage()
        end
    end
end

-- Accepts itemstring, returns list with sales
function exchange.search_by_itemstring(item)
    local sales = {}
    for _, obj in ipairs(exchange.offers) do
        if obj.item == item then
            table.insert(sales, obj)
        end
    end
    return sales
end

-- Accepts username, returns list with sales
function exchange.search_by_username(name)
    local sales = {}
    for _, obj in ipairs(exchange.offers) do
        if obj.seller == name then
            table.insert(sales, obj)
        end
    end
    return sales
end

-- Accepts keyword, returns list with sales that have keyword, ordered by increasing price
function exchange.search_by_keyword(keyword)
    local sales = {}
    keyword = string.lower(keyword)
    for _, obj in ipairs(exchange.offers) do
        if string.matches(obj.item, keyword) or string.matches(string.lower(ItemStack(obj.item):get_meta():get_string("description")), keyword) or string.matches(string.lower(obj.seller), keyword) then
            table.insert(sales, obj)
        end
    end
    sales = exchange.sort_by_increasing_price(sales)
    return sales
end

-- Sorts offers by increasing price
function exchange.sort_by_increasing_price(sales)
   local function compare(a, b)
        return a.price > b.price
    end
    table.sort(sales, compare)
end

-- Returns number of active offers
function exchange.get_number_of_offers()
    return #exchange.offers
end

-- Formats log messages nicely, trivial function
function exchange.log(message)
    minetest.log("[Exchange]" .. message)
end

-- Formats given list of offers to be used in formspecs
function exchange.fs_format(sales)
    local formatted = ""
    for _, obj in ipairs(sales) do
        formatted = formatted .. " " .. obj.item .. " for " .. obj.price .. " " .. exchange.currency .. " by " .. obj.seller .. ","
    end
    return formatted
end

-- Formats single offer to be used in formspecs
-- Only difference is that this version does not loop and omits the comma
-- Not for normal use, 90% of cases should use exchange.fs_format()
function exchange.fs_format_single(obj)
    return obj.item .. " for " .. obj.price .. " " .. exchange.currency .. " by " .. obj.seller
end

-- Shows exchange formspec to player
function exchange.show_formspec(name, sales)
    sales = sales or exchange.offers
    minetest.show_formspec(name, "exchange:form",
        "size[8,9;]" ..
        "label[0,0;Player Exchange\nBuy and sell]" ..
        "textlist[0,1;5,3.5;sales;" .. exchange.fs_format(sales) .. "]" ..
        "field[2.2,0.33;3,1;search;;]" ..
        "button[4.2,0;1,1;searchbutton;Search]" ..
        "button[5.4,0;2.6,1;buy;Buy selected item]" ..
        "list[current_player;main;0,5;8,4;]"
    )
end
