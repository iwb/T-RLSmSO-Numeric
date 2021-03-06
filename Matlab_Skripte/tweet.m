function tweet( message )
%tweet Tweets the message
    persistent TwitterObj;

    % Twittern ermöglichen am Matlab 2013b
    versionStr = version('-java');
    if strcmp(versionStr(1:8), 'Java 1.7')
        if isempty(TwitterObj)
            addpath('../twitty');            
            load('credentials.mat');
            
            try
                TwitterObj = twitty(c);
            catch
            end
        end
        try
            if exist('twitterPrefix', 'file')
               message = [twitterPrefix() message]; 
            end
            TwitterObj.updateStatus(message);
        catch
            % Fehler beim twittern werden geschluckt
        end
    end
end