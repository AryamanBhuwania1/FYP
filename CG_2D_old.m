function [P,er,rk] = CG_2D(x,y,h,W,E,pr,P)
% ==========================================
% this code is to determine the interfacial separation for a given load applied on a rough surface (2D).
% The iterative method used here is based on conjugate gradient method and
% the deformation integrals are computed using the FFT.
% This code is the improved version

% inputs are:
%       x x axis (m)
%       y y axis (m)
%       h roughness data (m)
%       W applied load (N)
%       E elastic modulus (MPa)
%       pr poisson ratio
%       P pressure to start calculation


% outputs are:
%       P pressure distribution (MPa)
%       er error
%       rk separation (m)

% ==========================================

    Nx = length(x);
    dx = x(2)-x(1);
    Ny = length(y);
    dy= y(2)-y(1);

    A = conn(Ny,dy,Nx,dx,E,pr);
    fA = fft2(A);

%     P = ones(Ny,Nx)*W/Nx/dx/Ny/dy; 
    errlim = 1e-10;
    Gold = 1;
    pk = zeros(Ny,Nx);
    err = 1;
    it = 0;

    while (err>errlim)
        it = it+1;
        s = find(P>0);
        sn = find(P<=0);
        
        % compute the residual rk
        dd = real(ifft2(fA.*fft2(P,2*Ny,2*Nx)));
        u = dd(1:Ny,1:Nx); clear dd
        rk = u+h; clear u
        do = mean(rk(s));
        rk = rk-do;
        
        % G norm2 of rk in the contact
        G = sum(rk(s).*rk(s));
        
        % computation of slope qk
        pk(s) = rk(s)+G/Gold*pk(s);
        pk(sn) = 0;
        Gold = G;
        
        % computation of qk
        dd = real(ifft2(fA.*fft2(pk,2*Ny,2*Nx)));
        qk = dd(1:Ny,1:Nx); clear dd
        rb = mean(qk(s));
        qk = qk-rb;
        
        % computation of the coef's alphak = dp
        dp = sum(rk(s).*pk(s))/sum(qk(s).*pk(s));
        
        Pold = P;
        P(s) = P(s)-dp*pk(s);
        s = find(P<0);
        P(s) = 0;
        sol = find((P==0)&(rk<0));
        P(sol) = P(sol)-dp*rk(sol);
        load = sum(sum(P))*dx*dy;
        P = W/load*P;
       
%         % use gap to check convergence
%         err = sqrt(Gold*dx*dy);
%         er(it) = err;
%         disp(num2str([it err],'%10.2g %10.2g'))
        
        %use pressure to check convergence
        err = sum(sum(abs(P-Pold)));
        err = err*dx*dy/W;
        er(it) = err;
        disp(num2str([it err],'%10.2g %10.2g'))
    end

function A = conn(Nx,dx,Ny,dy,E1,pr)
        Ee = 0.5*((1-pr^2)/E1);
        Ee = 1/Ee;
        C = 2/pi/Ee;
        px2 = dx/2;
        py2 = dy/2;
        XL = dx*Nx;
        YL = dy*Ny;
        xb = 0:dx:XL-px2;
        yb = 0:dy:YL-py2;
        [xxb,yyb] = meshgrid(xb,yb);
        xxm = xxb-px2;
        xxp = xxb+px2;
        yym = yyb-py2;
        yyp = yyb+py2;
        A = FNF(xxm,yym)+FNF(xxp,yyp)-FNF(xxm,yyp)-FNF(xxp,yym);
        A = C*A;
        A(Nx+1,:) = A(Nx,:);
        A(Nx+2:2*Nx,:) = A(Nx:-1:2,:);
        A(:,Ny+1) = A(:,Ny);
        A(:,Ny+2:2*Ny) = A(:,Ny:-1:2);
end

function reco = FNF(x,y)
        r = sqrt(x.*x+y.*y);
        reco = y.*log(x+r)+x.*log(y+r);
end

end
