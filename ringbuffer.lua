RingBuffer = {}


function RingBuffer:init(size,defaultValue)
    local rq = {
        index=1,
        capacity=size,
        data={},
    }
    if type(defaultValue) ~= "table" then
        for i = 1,size do
            rq.data[i] = defaultValue
        end
    else
        for i = 1,size do
            rq.data[i] = setmetatable({}, {__index=defaultValue})
        end
    end
    setmetatable(rq, self)
    self.__index = self
    return rq
end

function RingBuffer:size()
    return #self.data
end

function RingBuffer:capacity()
    return self.capacity
end

function RingBuffer:iterator()
    local count = 0
    local pos = self.index + 1
    return function ()
        count = count + 1
        pos = pos - 1
        if pos < 1 then pos = self.capacity end
        if count <= self.capacity then return self.data[pos] end
    end
end

function RingBuffer:nextIndex()
    if self.index < self.capacity then return self.index+1 else return 1 end
end

function RingBuffer:rotate()
    self.index = self:nextIndex()
end

function RingBuffer:insert(d)
    self:rotate()
    self.data[self.index] = d
end

function RingBuffer:current()
    return self.data[self.index]
end

function RingBuffer:next()
    return self.data[self:nextIndex()]
end


