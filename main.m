classdef main < handle
% main.m class for Expression and similar tasks.
    
    properties
        subjinfo
        block = {'Happy','Anger','Contempt','Interest'};
        type = 'Expression'; % Task-specific tweeks
        current_block
        vals = {'02','03','04','06','08','11','16','27','32','45','64','91'};
        soundfiles = {'applause','oops'};
        audio_on = 1;
        audio
        fix = 1;
        abort = 0;
        pracadd = 1; % Additional practice durations, added to timelim 1 and 3
        timelim = [4.5 .5 2]; % Response duration (1), ITI (2), Display duration (3 - optional)
        imgsize = [411 296 3];
        rescale = 2/3; % Selected to fit an upper_buffer and middle_buffer of 100 pixels
        monitor
        path
        text
        keys
        keymap
        cbfeed = [zeros([5 1]); ones([5 1])]; % Counter-balance measures
        out
    end
    
    methods
        %% Constructor
        function obj = main(varargin)
            
            % Query user: subject info, block order, kid/adult condition
            prompt={'Subject ID:','Age:','Gender:'};
            name='Experiment Info';
            numlines=1;
            defaultanswer={'','',''};
            s=inputdlg(prompt,name,numlines,defaultanswer);
            
            if isempty(s)
                error('User Cancelled.')
            end
            
            obj.subjinfo.sid = [s{1} '_' datestr(now,'mmddyy')];
            obj.subjinfo.age = s{2};
            obj.subjinfo.gender = s{3};
            
            if obj.rescale % Rescale obj.imgsize
                
                obj.imgsize(1) = ceil(obj.imgsize(1)*(obj.rescale));
                obj.imgsize(2) = ceil(obj.imgsize(2)*(obj.rescale));
                
            end
            
%             % Text prep
%             obj.text.withpic = 'Which face shows more expression?';
%             obj.text.leftarrow = '<';
%             obj.text.rightarrow = '>';
%             obj.text.goodbye = WrapString('Thank you for participating!  You are now finished with this portion of the study.');
            obj.text.cberr = 'Attempted to access cb(11,1); index out of bounds because size(cb)=[10,2].';
            
        end
        %%
        %% Dispset
        function [monitor] = dispset(obj)
            % 3/20/13
            % Ken Hwang
            % PSU, Scherf Lab, SLEIC, Dept. of Psych.
            
            % Determines monitor settings
            % Output: monitor data structure
            
            
            if ismac
                % Find out how many screens and use lowest screen number (laptop screen).
                whichScreen = min(Screen('Screens'));
            elseif ispc
                % Find out how many screens and use largest screen number (desktop screen).
                whichScreen = max(Screen('Screens'));
            end
            
            % Rect for screen
            rect = Screen('Rect', whichScreen);
            
            % Screen center calculations
            center_W = rect(3)/2;
            center_H = rect(4)/2;
            
            % ---------- Color Setup ----------
            % Gets color values.
            
            % Retrieves color codes for black and white and gray.
            black = BlackIndex(whichScreen);  % Retrieves the CLUT color code for black.
            white = WhiteIndex(whichScreen);  % Retrieves the CLUT color code for white.
            
            gray = (black + white) / 2;  % Computes the CLUT color code for gray.
            if round(gray)==white
                gray=black;
            end
            
            % Taking the absolute value of the difference between white and gray will
            % help keep the grating consistent regardless of whether the CLUT color
            % code for white is less or greater than the CLUT color code for black.
            absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);
            
            % Data structure for monitor info
            monitor.whichScreen = whichScreen;
            monitor.rect = rect;
            monitor.center_W = center_W;
            monitor.center_H = center_H;
            monitor.black = black;
            monitor.white = white;
            monitor.gray = gray;
            monitor.absoluteDifferenceBetweenWhiteAndGray = absoluteDifferenceBetweenWhiteAndGray;
            
            obj.monitor = monitor;
            
        end
        
        %% Pathset
        function pathset(obj)
            try
                obj.path.bin = [obj.path.base filesep 'bin'];
                obj.path.out = [obj.path.base filesep 'out'];
                obj.path.content = [obj.path.base filesep 'content'];
                contentcell = {'general','pictures'}; % Add to cell for new directories in 'content'
                for i = 1:length(contentcell)
                    obj.path.(contentcell{i}) = [obj.path.content filesep contentcell{i}];
                end
            catch ME
                disp(ME);
            end
        end
        %%
        
        %% Keyset
        function keyset(obj)
            % Key prep
            KbName('UnifyKeyNames');
            
            obj.keys.upkey = KbName('UpArrow');
            obj.keys.downkey = KbName('DownArrow');
            obj.keymap = [obj.keys.upkey obj.keys.downkey]; % Ordering: 1 = pic1, 2 = pic2
            
            obj.keys.esckey = KbName('Escape');
            obj.keys.spacekey = KbName('SPACE');
        end
        %%
        
        %% Cb
        function [cbout] = cb(obj)
            
            cbout = Shuffle(obj.cbfeed);
            cbout = [cbout ~cbout];
            
        end
        %%
        
        %% Imgload
        function [img, img0, img100] = imgload(obj,expr)
            try
                if obj.rescale % Rescale to parameter
                    img = zeros([obj.imgsize(1) obj.imgsize(2) obj.imgsize(3) length(obj.vals)]);
                    for i = 1:length(obj.vals)
                        img(:,:,:,i) = imresize(imread([obj.path.pictures filesep expr filesep expr obj.vals{i} '.jpg']),obj.rescale);
                        %                     img(:,:,:,i) = img(:,:,:,i)/max(max(max(img(:,:,:,i))));
                    end
                    
                    img0 = imresize(imread([obj.path.pictures filesep expr filesep expr '00.jpg']),obj.rescale);
                    %                 img0 = img0.*1.2; % 1.2 to compensate for Dot Gain in
                    img100 = imresize(imread([obj.path.pictures filesep expr filesep expr '100.jpg']),obj.rescale);
                    %                 img100 = img100.*1.2;
                else
                    
                    img = zeros([obj.imgsize(1) obj.imgsize(2) obj.imgsize(3) length(obj.vals)]);
                    for i = 1:length(obj.vals)
                        img(:,:,:,i) = imread([obj.path.pictures filesep expr filesep expr obj.vals{i} '.jpg']);
                        %                     img(:,:,:,i) = img(:,:,:,i)/max(max(max(img(:,:,:,i))));
                    end
                    
                    img0 = imread([obj.path.pictures filesep expr filesep expr '00.jpg']);
                    %                 img0 = img0.*1.2; % 1.2 to compensate for Dot Gain in
                    img100 = imread([obj.path.pictures filesep expr filesep expr '100.jpg']);
                    %                 img100 = img100.*1.2;
                end
                
                % Picture rects
                middle_buffer = 30;
                x_left = obj.monitor.center_W - (obj.imgsize(2)/2);
                x_right = obj.monitor.center_W + (obj.imgsize(2)/2);
                y1_top = (obj.monitor.center_H - middle_buffer/2) - obj.imgsize(1);
                y1_bottom = obj.monitor.center_H - middle_buffer/2;
                y2_top = obj.monitor.center_H + middle_buffer/2;
                y2_bottom = (obj.monitor.center_H + middle_buffer/2) + obj.imgsize(1);
                obj.monitor.rect1 = [x_left y1_top x_right y1_bottom];
                obj.monitor.rect2 = [x_left y2_top x_right y2_bottom];
                
            catch ME
                disp(ME);
            end
        end
        %%
        
        %% Imgshow
        function [tex1, tex2] = imgshow(obj,pic1,pic2)
            % pic1 (left), pic2 (right)
            tex1 = Screen('MakeTexture',obj.monitor.w,pic1);
            tex2 = Screen('MakeTexture',obj.monitor.w,pic2);
            Screen('DrawTexture',obj.monitor.w,tex1,[],obj.monitor.rect1);
            Screen('DrawTexture',obj.monitor.w,tex2,[],obj.monitor.rect2);
        end
        %%
        
        %% Imgshow2
        function [tex] = imgshow2(obj,picstring)
           picmat = imread(picstring);
           tex = Screen('MakeTexture',obj.monitor.w,picmat);
           Screen('DrawTexture',obj.monitor.w,tex);
        end
        
        %% Audioload
        function [pahandle] = audioload(obj)
            % Loading general content -- Audio
                try
                    addpath([obj.path.bin filesep 'mp3readwrite']); % Add mp3readwrite
                catch ME
                    throw(ME)
                end
  
            audio.dat = cell([length(obj.soundfiles) 1]);
            
            for i = 1:length(obj.soundfiles)
                audio.dat{i} = mp3read([obj.path.general filesep obj.soundfiles{i} '.mp3']);
            end
            
            InitializePsychSound;
            PsychPortAudio('DeleteBuffer');
            pahandle = PsychPortAudio('Open',[],[],0,44100,2); % 44100Hz, Stereo (2)
            audio.pahandle = pahandle;
            
            obj.audio = audio;
            
        end
        %%
        
        %% Playaudio
        function playaudio(obj,dat)
            buffer = PsychPortAudio('CreateBuffer',[],dat');
            PsychPortAudio('FillBuffer',obj.audio.pahandle,buffer);
            PsychPortAudio('Start',obj.audio.pahandle,1,0,0);
        end
        %%
        
        %% Practice
        function practice(obj,img100,img0)
            RestrictKeysForKbCheck([obj.keys.esckey obj.keymap]); 
            endflag = 0;
            while ~endflag
                if randi([0 1])
                    pic1 = 'img100';
                    pic2 = 'img0';
                    answer = obj.keymap(1);
                else
                    pic1 = 'img0';
                    pic2 = 'img100';
                    answer = obj.keymap(2);
                end
                
                [tex] = obj.imgshow2([obj.path.general filesep 'practrial.jpg']);
                [tex1,tex2] = obj.imgshow(eval(pic1),eval(pic2));
                Screen('Flip',obj.monitor.w);
                
                Screen('Close',tex);
                Screen('Close',tex1);
                Screen('Close',tex2);
%                 tic
                start = GetSecs;
                keyIsDown = 0;
                drop = 0;
                while (GetSecs-start) < (obj.timelim(1) + obj.pracadd)
                    
                    if ~drop
                        if numel(obj.timelim) >= 3
                            if (GetSecs-start) > (obj.timelim(3) + obj.pracadd)
                                [tex] = obj.imgshow2([obj.path.general filesep 'practrial.jpg']);
                                Screen('Flip',obj.monitor.w);
                                Screen('Close',tex);
                                drop = 1;
%                                 toc
                            end
                        end
                    end
                    
                    [keyIsDown,secs,keyCode]=KbCheck; %#ok<ASGLU>
                    if keyIsDown
                        if find(keyCode) == obj.keys.esckey
                            endflag = 1;
                            obj.abort = 1;
%                             disp('abort')
                        elseif find(keyCode) == answer
                            % Audio
%                             disp('Correct');
                            endflag = 1;
                            if obj.audio_on
                                obj.playaudio(obj.audio.dat{1});
                            end
                        else
                            % Audio
%                             disp('Incorrect');
                            if obj.audio_on
                                obj.playaudio(obj.audio.dat{2});
                            end
                        end
                        break;
                    end
                end
%                 toc
                
                if ~keyIsDown
%                    disp('Incorrect');
                   if obj.audio_on
                       obj.playaudio(obj.audio.dat{2});
                   end
                end
                                    
                if obj.fix
                    Screen('DrawLine',obj.monitor.w,obj.monitor.white,obj.monitor.center_W-20,obj.monitor.center_H,obj.monitor.center_W+20,obj.monitor.center_H,7);
                    Screen('DrawLine',obj.monitor.w,obj.monitor.white,obj.monitor.center_W,obj.monitor.center_H-20,obj.monitor.center_W,obj.monitor.center_H+20,7);
                end
                
                Screen('Flip',obj.monitor.w);
                pause(obj.timelim(2));
%                 toc
            end
        end
        
        %% Cycle
        function cycle(obj,img,img0)
            obj.datproc(1);
            endflag = 0;
            cb = obj.cb;
            i = 1;
            step = 11;
            track = 0;
            thresh = [];
            threshcalc = []; % Value used in thresh calculation (typically step above, but not if prior trial was incorrect)
            RestrictKeysForKbCheck([obj.keys.esckey obj.keymap]); 
            
            while ~endflag
                try
                    if i > size(cb,1)
                        i = 1;
                    end
                    
                    if cb(i,1)
                        pic1 = 'img(:,:,:,step)';
                        pic1name = [obj.current_block obj.vals{step}];
                        pic2 = 'img0';
                        pic2name = [obj.current_block '00'];
                        answer = obj.keymap(1);
                    else
                        pic1 = 'img0';
                        pic1name = [obj.current_block '00'];
                        pic2 = 'img(:,:,:,step)';
                        pic2name = [obj.current_block obj.vals{step}];
                        answer = obj.keymap(2);
                    end
                    
                    [tex] = obj.imgshow2([obj.path.general filesep 'trial.jpg']);
                    [tex1,tex2] = obj.imgshow(eval(pic1),eval(pic2));
                    Screen('Flip',obj.monitor.w);
                    
                    Screen('Close',tex);
                    Screen('Close',tex1);
                    Screen('Close',tex2);
%                     tic
                    start = GetSecs;
                    keyIsDown = 0;
                    drop = 0;
                    while (GetSecs-start) < obj.timelim(1)
                        
                        if ~drop
                            if numel(obj.timelim) >= 3
                                if (GetSecs-start) > obj.timelim(3)
                                    [tex] = obj.imgshow2([obj.path.general filesep 'trial.jpg']);
                                    Screen('Flip',obj.monitor.w);
                                    Screen('Close',tex);
                                    drop = 1;
%                                     toc
                                end
                            end
                        end
                        
                        [keyIsDown,secs,keyCode]=KbCheck; 
                        if keyIsDown
                            if find(keyCode) == obj.keys.esckey
                                endflag = 1;
                                obj.abort = 1;
%                                 disp('Aborted.')
                            elseif find(keyCode) == answer
%                                 disp('Correct'); % Temp
%                                 disp(obj.vals{step}); % Temp
                                % Audio
                                % Record
                                fprintf(obj.out.fid,'%s,%s,%s,%s,%s,%1.2f,%i,%i,%2.2f\n',obj.subjinfo.sid,obj.subjinfo.age,obj.subjinfo.gender,pic1name,pic2name,secs-start,1,0,thresh);
                                
                                threshcalc = str2double(obj.vals{step});
                                
                                if step == 1
                                    % Repeat step
                                elseif step < 1
                                    % Calculate thresh from lowest two
                                    % obj.vals and quit
                                    thresh = mean([threshcalc str2double(obj.vals{step+1})]);
                                    endflag = 1;
                                else
                                    step = step - 1;
                                end
                                
                            else
                                % Audio
                                % Record
%                                 disp('Incorrect'); % Temp
%                                 disp(obj.vals{step}); % Temp
                                
                                thresh = mean([mean([threshcalc str2double(obj.vals{step})]) thresh]);
                                threshcalc = thresh;
                                
                                fprintf(obj.out.fid,'%s,%s,%s,%s,%s,%1.2f,%i,%i,%2.2f\n',obj.subjinfo.sid,obj.subjinfo.age,obj.subjinfo.gender,pic1name,pic2name,secs-start,0,1,thresh);
                                
                                track = track + 1;
                                
                                if track == 5
                                    endflag = 1;
                                else
                                    step = step + 4;
                                    if step > length(obj.vals)
                                        step = length(obj.vals);
                                    end
                                end
                            end
                            break;
                        end
                    end
                    
                    if ~keyIsDown % No response
                        
                        % Audio???
                        fprintf(obj.out.fid,'%s,%s,%s,%s,%s,%1.2f,%i,%i,%2.2f\n',obj.subjinfo.sid,obj.subjinfo.age,obj.subjinfo.gender,pic1name,pic2name,[],0,1,thresh);
                        
                        track = track + 1;
                        if track == 5
                            endflag = 1;
                        else
                            step = step + 4;
                            if step > length(obj.vals)
                                step = length(obj.vals);
                            end
                        end
                    end
%                     toc
                    
%                     disp(obj.vals{step});
%                     disp(track);
                    
                    i = i + 1;
                    
                    if obj.fix
                        Screen('DrawLine',obj.monitor.w,obj.monitor.white,obj.monitor.center_W-20,obj.monitor.center_H,obj.monitor.center_W+20,obj.monitor.center_H,7);
                        Screen('DrawLine',obj.monitor.w,obj.monitor.white,obj.monitor.center_W,obj.monitor.center_H-20,obj.monitor.center_W,obj.monitor.center_H+20,7);
                    end
                    
                    Screen('Flip',obj.monitor.w);
                    pause(obj.timelim(2));
%                     toc
                    
                catch ME
                    if strcmp(ME.message,obj.text.cberr)
                        cb = obj.cb;
                        i = 1;
                    else
                        disp(ME.message)
                        endflag = 1;
%                         break;
                    end
                end
            end
        end
        %%
        
        %% Datproc
        function datproc(obj,type)
            if type == 1
                obj.out.h = {'Subject','Age','Gender','Above','Below','RT','Acc','Reversal','Thresh Avg.'};
                obj.out.fid = fopen([obj.path.out filesep obj.subjinfo.sid '_Female.csv'],'a');
                fprintf(obj.out.fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s\n',obj.out.h{:});
            elseif type == 2
                
                try
                    obj.out.h2 = {'Subject','Age','Gender','Condition','TotalTrials','Reversals','FinalThresh','CorrectRT','IncorrectRT'};
                    obj.out.fid2 = fopen([obj.path.out filesep obj.subjinfo.sid '_Female.csv']);
                    dat = textscan(obj.out.fid2, '%s%s%s%s%s%s%s%s%s','Delimiter',',');
                    dat = [dat{:}];
                    cond = 0;
                    head = [];
                    
                    for i = 1:size(dat,1)
                        if all(strcmp(dat(i,:),obj.out.h));
                            head = [head i];
                            cond = cond + 1;
                        end
                    end
                    
                    if (head(end) + 1) > size(dat,1)
                        head = head(1:end-1);
                    end
                        
                    condnames = cellfun(@(y)(regexprep(y,'(\d{2,3})$','')),dat(head + 1,4),'UniformOutput',false);
                    
                    for i = 1:length(head)
                        if i == length(head)
                            x2 = 'end';
                        else
                            x2 = 'head(i + 1)-1';
                        end
                        dat2.(condnames{i}) = eval(['dat(head(i)+1:' x2 ',:);']);
                    end
                    
                    out2 = cell([length(condnames) length(obj.out.h2)]);
                    [out2(:,1)] = deal({obj.subjinfo.sid}); % SID
                    [out2(:,2)] = deal({obj.subjinfo.age}); % Age
                    [out2(:,3)] = deal({obj.subjinfo.gender}); % Gender
                    out2(:,4) = condnames; % Condition names
                    
                    for i = 1:length(condnames)
                        out2{i,5} = size(dat2.(condnames{i}),1); % Total trials
                        rev = regexp([dat2.(condnames{i}){1:end,8}],'1');
                        correct = setxor(1:size(dat2.(condnames{i}),1),rev);
                        
                        if ~isempty(rev)
                            out2{i,6} = length(rev); % Reversals
                        end
                        
                        out2{i,7} = str2num(dat2.(condnames{i}){end,end}); %#ok<*ST2NM> % Final Threshold
                        corrRT = cellfun(@(y)(str2num(y)),dat2.(condnames{i})(correct,6),'UniformOutput',false);
                        out2{i,8} = mean([corrRT{:}]); % Mean correct RT
                        
                        if ~isempty(rev)
                            incorrRT = cellfun(@(y)(str2num(y)),dat2.(condnames{i})(rev,6),'UniformOutput',false);
                            out2{i,9} = mean([incorrRT{:}]); % Mean incorrect RT
                        end
                        
                    end
                    
                    cell2csv([obj.path.out filesep obj.subjinfo.sid '_Female_summary.csv'],[obj.out.h2; out2]);
                    
                catch ME
                    throw(ME)
                end
            end
        end
    end
    
end

