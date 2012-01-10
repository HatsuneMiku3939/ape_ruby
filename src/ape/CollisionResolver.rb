module APE
	class CollisionResolver
		def self.resolve(pa, pb, normal, depth)
			mtd = normal.mult(depth)
			te = pa.elasticity + pb.elasticity
			sum_inv_mass = pa.inv_mass + pb.inv_mass
			
			tf = MathUtil.clamp(1 - (pa.friction + pb.friction), 0, 1)
			
			ca = pa.get_components(normal)
			cb = pb.get_components(normal)
		
			cbvn = cb.vn.mult((te + 1) * pa.inv_mass)
			cavn = ca.vn.mult(pb.inv_mass - te * pa.inv_mass);
			vn_a = cbvn.plus(cavn).div_equals(sum_inv_mass);

			cavn = ca.vn.mult((te + 1) * pb.inv_mass);
			cbvn = cb.vn.mult(pa.inv_mass - te * pb.inv_mass);
			vn_b = cavn.plus(cbvn).div_equals(sum_inv_mass);
							 
			ca.vt.mult_equals(tf)
			cb.vt.mult_equals(tf)
			
			mtd_a = mtd.mult(pa.inv_mass / sum_inv_mass)
			mtd_b = mtd.mult(-pb.inv_mass / sum_inv_mass)
		
			vn_a.plus_equals(ca.vt)
			vn_b.plus_equals(cb.vt)

			pa.resolve_collision(mtd_a, vn_a, normal, depth, -1, pb)
			pb.resolve_collision(mtd_b, vn_b, normal, depth, +1, pa)
		end
	end
end
