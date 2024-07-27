import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export default function Devices() {
    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Devices</PageHeaderHeading>
            </PageHeader>
            <Card>
                <CardHeader>
                    <CardTitle>Coming soon</CardTitle>
                    <CardDescription>Good things take time. Great things take a little longer. -John Wooden</CardDescription>
                </CardHeader>
            </Card>
        </>
    )
}
