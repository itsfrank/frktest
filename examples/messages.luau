local frktest = require("./../src/frktest.luau")
local test = frktest.test
local check = frktest.assert.check
local req = frktest.assert.require
local msg = frktest.assert.msg

return function()
    test.suite("Messages", function()
        test.case("Print message if assertion fails", function()
            check.equal(10, 20, msg("the check failed and has a message"))
            local exp = 20
            req.equal(10, exp, msg(`messages can use interpolation: {exp}`))
        end)

        test.case("Message doesn't have to be in assertion", function()
            -- because of the way it's implemented, msg can be called before the check
            msg("message on different line")
            check.equal(1, 2)
        end)

        test.case("There can only be one message at a time", function()
            msg("this message will never print")
            check.equal(1, 2, msg("this message overwrote the one above"))
        end)

        test.case("Messages only affect the next assertion", function()
            -- messages are forgotten after each assertion, whether is passes or fails
            -- but only printed if the assertion fails
            msg("this message will never print")
            check.equal(1, 1) -- this assertions passes, but the message is still forgotten
            check.equal(1, 2) -- prints no custom message
        end)
    end)
end
