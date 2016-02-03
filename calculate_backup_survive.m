function [temp] = calculate_backup_survive(ADJ,p)

  temp = true;
  for k=1:length(p)-1
    if ADJ(p(k),p(k+1))==0
      temp = false;
      break;
    end
  end
