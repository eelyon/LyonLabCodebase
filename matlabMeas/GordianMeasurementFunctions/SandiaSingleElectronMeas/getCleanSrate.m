function [] = getCleanSrate(f_slow, f_fast, max_srate)
% Find lowest SRATE <= max_srate that gives exact frequencies for both clocks.
    lcm_constraint = lcm(6*f_slow, 6*f_fast);
    k = floor(max_srate / lcm_constraint);
    if k < 1
        error('Cannot satisfy both frequencies within %.0f MSa/s', max_srate/1e6);
    end
    srate = k * lcm_constraint;
    fprintf('Clean SRATE: %.4f MSa/s\n', srate/1e6);
    fprintf('  f_slow actual: %.4f kHz (T=%d samp)\n', srate/round(srate/f_slow)/1e3, round(srate/f_slow));
    fprintf('  f_fast actual: %.4f kHz (T=%d samp)\n', srate/round(srate/f_fast)/1e3, round(srate/f_fast));
end