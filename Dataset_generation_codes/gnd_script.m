load('train_gnd');
load('gnd_original');
load('image_id');
j=1;
for i=1:size(gnd_train,1);
    for j=1:size(image_id,1)
        if (gnd_train(i)==image_id(j))
            %display(image_id(i));
            train_gnd(i,1)=gnd_train(i);
            train_gnd(i,2)=VarName3(j);
        end
    end
end
