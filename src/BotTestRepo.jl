module BotTestRepo

using Compat

function f(x,y,  z)
    return x+y + z
end

Compat.UTF8String("hello")

print(1,2, 3)

[i for i in 1:2 if all([c for c in a])]

end
