function [std] = getStdOfStack(stack, mean)
    import java.util.*;
    sum = 0;
    elementNum = stack.size();
    for elementIDX=1 : elementNum
        sum = sum + (stack.pop() - mean)^2;
    end
    std = sqrt(sum / elementNum);
end