using Revise
using Omega

function popModel_(ω, sex)
    # sex = step_dis_(ω, [(0,1,0.3307), (1,2,0.6693)])
    # sex = Omega.categorical(ω, [0.3307, 0.6693])
    # sex -= 0.5
    if sex < 1
        capital_gain = normal(ω, 568.4105, 24248365.5428)
        if capital_gain < 7298.0000
            age = normal(ω, 38.4208, 184.9151)
            education_num = normal(ω, 10.0827, 6.5096)
            capital_loss = normal(ω, 86.5949, 157731.9553)
        else
            age = normal(ω, 38.8125, 193.4918)
            education_num = normal(ω, 10.1041, 6.1522)
            capital_loss = normal(ω, 117.8083, 252612.0300)
        end
    else
        capital_gain = normal(ω, 1329.3700, 69327473.1006)
        if capital_gain < 5178.0000
            age = normal(ω, 38.6361, 187.2435)
            education_num = normal(ω, 10.0817, 6.4841)
            capital_loss = normal(ω, 87.0152, 161032.4157)
        else
            age = normal(ω, 38.2668, 187.2747)
            education_num = normal(ω, 10.0974, 7.1793)
            capital_loss = normal(ω, 101.7672, 189798.1926)
        end
    end

    if (education_num > age)
        age = education_num
    end
    # sensitiveAttribute(sex < 1)
    # qualified(age > 18)
    return (sex, age, education_num, capital_gain)
end

function popModel(ω)
    sex = Omega.categorical(ω, [0.3307, 0.6693])
    sex -= 0.5
    return popModel_(ω,sex)
end

W_h1 = randarray([normal(-0.2277,1.0), normal(0.6434,1.0), normal(2.3643,1.0)])
b_h1 = normal(3.7146,1.0)

W_h2 = randarray([normal(-0.0236,1.0), normal(-3.3556,1.0), normal(-1.8183,1.0)])
b_h2 = normal(-1.7810,1.0)

W_o1 = randarray([normal(0.4865, 1.0), normal(1.0685, 1.0)])
b_o1 = normal(-1.8079,1.0)

W_o2 = randarray([normal(1.7044, 1.0), normal(-1.3880, 1.0)])
b_o2 = normal(0.6830,1.0)

function F(ω, sex, age, education_num, capital_gain)
    N_age = ((age - 17.0) / 73.0  - 0.5) * 10 + 0.5
    N_education_num = ((education_num - 3.0) / 13.0  - 0.5) * 10 + 0.5
    N_capital_gain = ((capital_gain - 0.0) / 22040.0 - 0.5) * 10 + 0.5
    h1 = W_h1[1](ω) * N_age +  W_h1[2](ω) * N_education_num +  W_h1[3](ω) * N_capital_gain +  b_h1(ω)
    if h1 < 0
        h1 = 0
    end
    h2 = W_h2[1](ω) * N_age +  W_h2[2](ω) * N_education_num +  W_h2[3](ω) * N_capital_gain +  b_h2(ω)
    if h2 < 0
        h2 = 0
    end
    o1 =  W_o1[1](ω) * h1 +  W_o1[2](ω) * h2 + b_o1(ω)
    if o1 < 0
        o1 = 0
    end
    o2 =  W_o2[1](ω) * h1 + W_o2[2](ω) * h2 +  b_o2(ω)
    if o2 < 0
        o2 = 0
    end
    return o1 < o2
end

# the activation of F
function F_act(ω, sex, age, education_num, capital_gain)
    N_age = ((age - 17.0) / 73.0  - 0.5) * 10 + 0.5
    N_education_num = ((education_num - 3.0) / 13.0  - 0.5) * 10 + 0.5
    N_capital_gain = ((capital_gain - 0.0) / 22040.0 - 0.5) * 10 + 0.5
    h1 = W_h1[1](ω) * N_age +  W_h1[2](ω) * N_education_num +  W_h1[3](ω) * N_capital_gain +  b_h1(ω)
    if h1 < 0
        h1 = 0
        act_h1 = false
    else
        act_h1 = true
    end
    h2 = W_h2[1](ω) * N_age +  W_h2[2](ω) * N_education_num +  W_h2[3](ω) * N_capital_gain +  b_h2(ω)
    if h2 < 0
        h2 = 0
        act_h2 = false
    else
        act_h2 = true
    end
    o1 =  W_o1[1](ω) * h1 +  W_o1[2](ω) * h2 + b_o1(ω)
    if o1 < 0
        o1 = 0
        act_o1 = false
    else
        act_o1 = true
    end
    o2 =  W_o2[1](ω) * h1 + W_o2[2](ω) * h2 +  b_o2(ω)
    if o2 < 0
        o2 = 0
        act_o2 = false
    else
        act_o2 = true
    end
    return (act_h1, act_h2, act_o1, act_o2, o1 < o2)
end

# the gradient of F such that F changes the currrent output.
function F_grad(ω, sex, age, education_num, capital_gain)
    input_grad = [1.0, 1.0, 1.0]
    input_grad[1] *= 10.0/73.0
    input_grad[2] *= 10.0/13.0
    input_grad[3] *= 10.0/22040.0

    (act_h1, act_h2, act_o1, act_o2, result) = F_act(ω, sex, age, education_num, capital_gain)

    if act_h1
        h1_grad = input_grad .* W_h1(ω)
    else
        h1_grad = (0, 0, 0)
    end

    if act_h2
        h2_grad = input_grad[1] .* W_h2(ω)
    else
        h2_grad = (0, 0, 0)
    end

    if act_o1
        o1_grad = (h1_grad[1] * W_o1(ω)[1] + h2_grad[1] * W_o1(ω)[2],
        h1_grad[2] * W_o1(ω)[1] + h2_grad[2] * W_o1(ω)[2],
        h1_grad[3] * W_o1(ω)[1] + h2_grad[3] * W_o1(ω)[2])
    else
        o1_grad = (0, 0, 0)
    end

    if act_o2
        o2_grad = (h1_grad[1] * W_o2(ω)[1] + h2_grad[1] * W_o2(ω)[2],
        h1_grad[2] * W_o2(ω)[1] + h2_grad[2] * W_o2(ω)[2],
        h1_grad[3] * W_o2(ω)[1] + h2_grad[3] * W_o2(ω)[2])
    else
        o2_grad = (0, 0, 0)
    end

    if result
        return (0.0, o1_grad[1] - o2_grad[1], o1_grad[2] - o2_grad[2], o1_grad[3] - o2_grad[3])
    end

    return (0.0, o2_grad[1] - o1_grad[1], o2_grad[2] - o1_grad[2], o2_grad[3] - o1_grad[3])
end

# State stability. Here we use KL, following Zenna's idea. But is this right?
ϵ = 0.1
input(ω) = popModel(ω)
output(ω) = F(ω, input(ω)[1], input(ω)[2], input(ω)[3], input(ω)[4])
δ(ω) =  ϵ.*F_grad(ω, input(ω)[1], input(ω)[2], input(ω)[3], input(ω)[4])
perturb_input(ω) = input(ω) .+ δ(ω)
perturb_output(ω) = F(ω, perturb_input(ω)[1], perturb_input(ω)[2], perturb_input(ω)[3], perturb_input(ω)[4])

output_ = iid(output)
perturb_output_ = iid(perturb_output)

# TODO: conditioning on KL draw samples of the parameters

# Alternative: pointwise:
class_same(ω) = (output(ω) == perturb_output(ω))
class_same_ = iid(class_same; T= Bool)
stability = prob(class_same_∥ (W_h1, b_h1, W_h2, b_h2, W_o1, b_o1, W_o2, b_o2)) > 0.8 # 80% points robust

W_h1_samples = mean(rand(W_h1, stability))

b_h1_samples = mean(rand(b, stability))

println("W_h1: $(W_h1_samples)")

println("b_h1: +$(b_h1_samples)")