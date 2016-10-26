function runExpression(varargin)
% Any arguments in are assumed to be property changes.

% Directory setup
p = mfilename('fullpath');
[p,~,~] = fileparts(p);

% Bin
mainpath = which('main.m');
if ~isempty(mainpath)
    [mainext,~,~] = fileparts(mainpath);
    rmpath(mainext);
end

bin = [p filesep 'bin'];
addpath(bin);

% Object setup
obj = main;
obj.path.base = p;

if nargin > 0 % Property additions
    for nargs = 1:nargin
        if isstruct(varargin{nargs})
            fnames = fieldnames(varargin{nargs});
            for j = 1:length(fnames)
                obj.(inputname(nargs)).(fnames{j}) = varargin{nargs}.(fnames{j});
            end
        else
            obj.(inputname(nargs)) = varargin{nargs};
        end
    end
end

obj.pathset;

% Diary
d_file = datestr(now,30);
diary([obj.path.out filesep d_file]);

% Preseentation set-up
ListenChar(2);
HideCursor;

if ispc
    ShowHideWinTaskbarMex(0)
end

try
    fprintf('\nExpression: Key set-up ...\n')
    obj.keyset;
    fprintf('\nExpression: Done!\n')
catch ME
    throw(ME)
end

try
    fprintf('\nExpression: Monitor set-up ...\n')
    obj.dispset;
    fprintf('\nExpression: Done!\n')
catch ME
    throw(ME)
end

if obj.audio_on
    try
        fprintf('\nExpression: Audio set-up ...\n')
        obj.audioload;
        fprintf('\nExpression: Done!\n')
    catch ME
        throw(ME)
    end
end

try
    fprintf('\nExpression: Window set-up ...\n')
    % Open and format window
    obj.monitor.w = Screen('OpenWindow',obj.monitor.whichScreen,obj.monitor.black);
    Screen('BlendFunction', obj.monitor.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('TextSize',obj.monitor.w,30);
    fprintf('\nExpression: Done!\n')
catch ME
    throw(ME)
end

try
    fprintf('\nExpression: Beginning practice ...\n')
    [tex] = obj.imgshow2([obj.path.general filesep 'intro.jpg']);
    Screen('Flip',obj.monitor.w);
    
    Screen('Close',tex);
    RestrictKeysForKbCheck(obj.keys.spacekey);
    KbStrokeWait;
    
    prac = randsample(obj.block,4);
    
    for i = 1:length(prac)
        [~, img0, img100] = obj.imgload(prac{i});
        obj.practice(img100,img0);
        if obj.abort
            break;
        end
    end
    
    fprintf('\nExpression: Done!\n')
    
end

if obj.abort % Abort after practice -- skip cycle()
else
    
    try
        fprintf('\nExpression: Beginning task ...\n')
        
        [tex] = obj.imgshow2([obj.path.general filesep 'begin.jpg']);
        Screen('Flip',obj.monitor.w);
        
        Screen('Close',tex);
        RestrictKeysForKbCheck(obj.keys.spacekey);
        KbStrokeWait;
        
        % Randomize block
        s_block = Shuffle(obj.block);
        
        for i = 1:length(s_block)
            
            
            [tex1] = obj.imgshow2([obj.path.general filesep 'blockbegin.jpg']);
            [tex2] = obj.imgshow2([obj.path.pictures filesep s_block{i} filesep s_block{i} '100.jpg']);
            Screen('Flip',obj.monitor.w);
            
            Screen('Close',tex1);
            Screen('Close',tex2);
            RestrictKeysForKbCheck(obj.keys.spacekey);
            KbStrokeWait;
            
            obj.current_block = s_block{i};
            [img, img0, ~] = obj.imgload(s_block{i});
            obj.cycle(img,img0);
            
            % Abort mid-task (Still process partial summary)
            if obj.abort
                break;
            end
            
        end
        
        fclose(obj.out.fid);
        
        obj.datproc(2);
        %     disp('Task finished.');
        
        [tex] = obj.imgshow2([obj.path.general filesep 'outro.jpg']);
        Screen('Flip',obj.monitor.w);
        
        Screen('Close',tex);
        RestrictKeysForKbCheck([]);
        KbStrokeWait;
        
        fprintf('\nExpression: Done!\n')
    catch ME
        throw(ME)
    end
    
end
% Clean up
ListenChar(0);
ShowCursor;

if ispc
    ShowHideWinTaskbarMex(1)
end

if obj.audio_on
    PsychPortAudio('Close', obj.audio.pahandle); % Close pahandle
end
Screen('CloseAll');

rmpath(bin);

end