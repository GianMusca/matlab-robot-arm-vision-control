function [imagen]=generarlinea(rho,tita,utot,vtot)
vc=zeros(1,utot);
imagen=zeros(vtot,utot);
for i=1:utot
    vc(i)=round(-i*tan(tita)+(rho/cos(tita)));
end
vc=(vc.*(vc>0)).*(vc<vtot);
vc=vc+(vc==0);
for i=1:utot
    imagen(vc(i),i)=1;
end
imagen(1,:)=zeros(1,utot);

%espejo

uc=zeros(1,vtot);
for i=1:vtot
    uc(i)=round(-(i/tan(tita))+(rho/sin(tita)));
end

uc=(uc.*(uc>0)).*(uc<utot);
uc=uc+(uc==0);
for i=1:vtot
    imagen(i,uc(i))=1;
end
imagen(:,1)=zeros(1,vtot);
end