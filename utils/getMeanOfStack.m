function [mean] = getMeanOfStack(stack)
    import java.util.*;
    sum = 0;
    elementNum = stack.size();
    for elementIDX=1 : elementNum
        sum = sum + stack.pop();
    end
    mean = sum / elementNum;
end