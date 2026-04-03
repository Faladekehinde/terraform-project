Here’s a clean, professional **README.md** for your Day 10 task 👇

---

````markdown
# Day 10: Terraform Loops and Conditionals — Dynamic Infrastructure at Scale

## 📌 Overview
On Day 10 of the 30-Day Terraform Challenge, I explored how to eliminate repetitive configurations by using Terraform’s looping and conditional features. This marks a transition from static infrastructure definitions to dynamic, scalable, and reusable configurations.

---

## 🎯 Objectives
- Understand and apply `count` and `for_each`
- Learn how to use `for` expressions for data transformation
- Implement conditional logic using the ternary operator
- Refactor existing infrastructure to remove duplication
- Improve module reusability and scalability

---

## 🛠️ Key Concepts Learned

### 1. `count`
Used to create multiple identical resources.

```hcl
resource "aws_iam_user" "example" {
  count = 3
  name  = "user-${count.index}"
}
````

⚠️ Limitation: Index-based tracking can cause unintended resource recreation when list order changes.

---

### 2. `for_each`

Preferred for dynamic resources with unique identities.

```hcl
resource "aws_iam_user" "example" {
  for_each = toset(["alice", "bob", "charlie"])
  name     = each.value
}
```

✔ Stable
✔ Tracks resources by key instead of index

---

### 3. `for` Expressions

Used to transform data structures.

```hcl
output "upper_names" {
  value = [for name in var.user_names : upper(name)]
}
```

---

### 4. Conditionals (Ternary Operator)

```hcl
count = var.enable_autoscaling ? 1 : 0
```

Used for:

* Optional resources
* Environment-based configurations

---

## 🔧 Implementation

### ✅ Dynamic Subnets with `for_each`

```hcl
resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id            = aws_vpc.lab.id
  cidr_block        = each.value.cidr_block
  availability_zone = data.aws_availability_zones.available.names[each.value.az_index]
}
```

### ✅ Referencing Dynamic Resources

```hcl
values(aws_subnet.subnets)[*].id
```

---

### ✅ Conditional Autoscaling

```hcl
resource "aws_autoscaling_group" "asg" {
  count = var.enable_autoscaling ? 1 : 0
}
```

---

### ✅ Environment-Based Instance Sizing

```hcl
locals {
  instance_type = var.environment == "production" ? "t2.medium" : "t2.micro"
}
```

---

## 🚧 Challenges & Fixes

| Issue                          | Cause                  | Solution                                  |
| ------------------------------ | ---------------------- | ----------------------------------------- |
| Unsupported argument `subnets` | Old module version     | Updated module and version tag            |
| Missing subnet resources       | Switched to `for_each` | Updated references to `values(...)[*].id` |
| Typo (`lacal`)                 | Human error            | Corrected to `local`                      |
| Missing outputs                | Not defined in module  | Added `outputs.tf`                        |
| Git tag not found              | Not pushed             | `git push origin v0.0.3`                  |

---

## 🧪 Testing

### Enable Autoscaling

```hcl
enable_autoscaling = true
```

✔ Resource created

### Disable Autoscaling

```hcl
enable_autoscaling = false
```

✔ Resource skipped or destroyed

---

## 📚 Key Takeaways

* `count` is simple but fragile for dynamic lists
* `for_each` provides stability and should be preferred
* `for` expressions help reshape data cleanly
* Conditionals allow flexible, environment-aware infrastructure
* Always update references when refactoring resources

---

## 🚀 Outcome

* Eliminated repetitive code
* Built scalable and reusable modules
* Improved infrastructure reliability
* Gained deeper understanding of Terraform internals

---

## 🏁 Conclusion

Day 10 introduced the tools that make Terraform truly powerful. By mastering loops and conditionals, infrastructure can now be defined once and scaled effortlessly without duplication.

---

## 🔗 Next Steps

* Apply these patterns across all environments (dev, staging, production)
* Continue improving module versioning and reusability
* Prepare for Terraform Associate exam scenarios

---

#30DayTerraformChallenge #Terraform #IaC #DevOps

```
```
