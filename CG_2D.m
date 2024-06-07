function [P, er, rk] = CG_2D(x, y, h, W, E, pr, P)
    % ==========================================
    % This code is to determine the interfacial separation for a given load applied on a rough surface (2D).
    % The iterative method used here is based on the conjugate gradient method and
    % the deformation integrals are computed using the FFT.
    % This code is the improved version

    % Inputs are:
    %   x: x axis (m)
    %   y: y axis (m)
    %   h: roughness data (m)
    %   W: applied load (N)
    %   E: elastic modulus (MPa)
    %   pr: Poisson's ratio
    %   P: pressure to start calculation

    % Outputs are:
    %   P: pressure distribution (MPa)
    %   er: error
    %   rk: separation (m)
    % ==========================================

    Nx = length(x);
    dx = x(2) - x(1);
    Ny = length(y);
    dy = y(2) - y(1);

    A = conn(Ny, dy, Nx, dx, E, pr);
    fA = fft2(A);

    errlim = 1e-10;
    Gold = 1;
    pk = zeros(Ny, Nx);
    err = 1;
    it = 0;
    max_iter = 18000; % Maximum iteration count

    while (err > errlim) && (it < max_iter)
        it = it + 1;
        s = find(P > 0);
        sn = find(P <= 0);

        % Compute the residual rk
        dd = real(ifft2(fA .* fft2(P, 2 * Ny, 2 * Nx)));
        u = dd(1:Ny, 1:Nx);
        rk = u + h;
        do = mean(rk(s));
        rk = rk - do;

        % G norm2 of rk in the contact
        G = sum(rk(s) .* rk(s));

        % Computation of slope qk
        pk(s) = rk(s) + G / Gold * pk(s);
        pk(sn) = 0;
        Gold = G;

        % Computation of qk
        dd = real(ifft2(fA .* fft2(pk, 2 * Ny, 2 * Nx)));
        qk = dd(1:Ny, 1:Nx);
        rb = mean(qk(s));
        qk = qk - rb;

        % Computation of the coefficients alphak = dp
        dp = sum(rk(s) .* pk(s)) / sum(qk(s) .* pk(s));

        Pold = P;
        P(s) = P(s) - dp * pk(s);
        s = find(P < 0);
        P(s) = 0;
        sol = find((P == 0) & (rk < 0));
        P(sol) = P(sol) - dp * rk(sol);
        load = sum(sum(P)) * dx * dy;
        P = W / load * P;

        % Use pressure to check convergence
        err = sum(sum(abs(P - Pold)));
        err = err * dx * dy / W;
        er(it) = err;
        disp(num2str([it, err], '%10.2g %10.2g'))
    end

    function A = conn(Nx, dx, Ny, dy, E1, pr)
        Ee = 0.5 * ((1 - pr^2) / E1);
        Ee = 1 / Ee;
        C = 2 / pi / Ee;
        px2 = dx / 2;
        py2 = dy / 2;
        XL = dx * Nx;
        YL = dy * Ny;
        xb = 0:dx:XL - px2;
        yb = 0:dy:YL - py2;
        [xxb, yyb] = meshgrid(xb, yb);
        xxm = xxb - px2;
        xxp = xxb + px2;
        yym = yyb - py2;
        yyp = yyb + py2;
        A = FNF(xxm, yym) + FNF(xxp, yyp) - FNF(xxm, yyp) - FNF(xxp, yym);
        A = C * A;
        A(Nx + 1, :) = A(Nx, :);
        A(Nx + 2:2 * Nx, :) = A(Nx:-1:2, :);
        A(:, Ny + 1) = A(:, Ny);
        A(:, Ny + 2:2 * Ny) = A(:, Ny:-1:2);
    end

    function reco = FNF(x, y)
        r = sqrt(x .* x + y .* y);
        reco = y .* log(x + r) + x .* log(y + r);
    end

end
