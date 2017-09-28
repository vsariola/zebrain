p={'units','normalized','position',[0 0 1 1]};
figure(p{:});
axes(p{:});
toc = @(p) p(:,1)+j*p(:,2);

width = 470; % facebook size;
height = 264;
frames = 500;
draft = 1; % is this draft quality?
alpha = 1.5;
video = 0;

if (draft)
    width = width/2;
    height = height/2;
    frames = frames/4;
end

f = [0 0;0 0.5;0 1;0 1.5;0 2;5 1;0.5 2;1 2;0.5 1;1 1];
r = [0 0;0 0.5;0 1;0 1.5;0 2;0.5 2;1 1.5;0.5 1;1 0.5;1 0];
e = [0 0;0 0.5;0 1;0 1.5;0 2;0.5 2;1 2;0.5 1;0.5 0;1 0];
t = [0.5 0;0.5 0.5;0.5 1;0.5 1.5;0 2;0.2 2;0.4 2;0.6 2;0.8 2;1 2];
h = [0 0;0 0.6;0 1.4;0 2;1 0;1 0.6;1 1.4;1 2;0.33 1;0.67 1];
p = [0 0;0 0.4;0 0.8;0 1.2;0 1.6;0 2;0.5 2;1 1.66;0.5 1;1 1.33];
i = [ones(10,1)*0.5 linspace(0,2,10)'];
x = [0 0;0.25 0.5;0.5 1;0.25 1.5;0 2;1 0;0.75 0.5;5 1;0.75 1.5;1 2];
u = repmat([0.5 1],10,1);
l = [[zeros(6,1) linspace(0,2,6)'];[linspace(0.2,1,4)' zeros(4,1)]];
s = [0.5 2;1 2;0.33 1;0.67 1;0 0;0.5 0;0 1.33;0 1.67;1 0.33;1 0.67];

r = [toc(u) toc(u) toc(f) toc(r) toc(e) toc(e) toc(u) toc(t) toc(h) toc(e) toc(u) toc(p) toc(i) toc(x) toc(e) toc(l) toc(s) toc(u)];
N = size(f,1);
for i = 1:size(r,2)
    r(:,i) = r(randperm(N),i);
end
szA = size(r); 
[x,y] = meshgrid(linspace(-0.5,1.5,width),linspace(-0.5,2.5,height));
%[x,y] = meshgrid(linspace(-0.5,1.5,130),linspace(-0.5,2.5,80));
n = 5;
r = reshape(repmat(r,n,1),szA(1),n*szA(2));
tt = 1:size(r,2);
a = 0.8 + 0.13j;
colormap('bone');
if video
    mov = avifile('example4.avi','fps',25);
end
 for t = linspace(1,size(r,2),frames)
    c = x+y*j;
    rr = spline(tt,real(r),t)+j*spline(tt,imag(r),t);
    k = zeros(size(c));
    w = 0;
    for i = 1:5
       fprev = f;
       f = zeros(size(c));
       for k = 1:N
           f = f + 1./(c-rr(k));
       end
       f = 1 ./ f;
       c = c - a*f; 
       k = k + log(1./abs(f)) * alpha^i;
       w = w + alpha^i;
    end
    img = 18*flipud(k/w)-10;
    rgb = ind2rgb(uint8(img),colormap);
    image(rgb);
    if video
        mov = addframe(mov,rgb);
    end
    drawnow;
 end
if video
    mov = close(mov);
end
close all